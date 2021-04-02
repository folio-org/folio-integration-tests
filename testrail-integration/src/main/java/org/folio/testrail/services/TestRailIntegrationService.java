package org.folio.testrail.services;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import net.masterthought.cucumber.json.support.Status;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.dao.CasesDao;
import org.folio.testrail.dao.ResultsDao;
import org.folio.testrail.dao.RunsDao;
import org.folio.testrail.dao.SectionsDao;
import org.folio.testrail.models.TestRailStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.core.Scenario;
import com.intuit.karate.core.ScenarioResult;
import com.intuit.karate.core.Step;
import com.intuit.karate.core.StepResult;

import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

public class TestRailIntegrationService {

  private static final Logger logger = LoggerFactory.getLogger(TestRailIntegrationService.class);
  private static final String PROJECT_NAME = "ThunderJet";
  private static final String ID = "id";

  private Long projectId;
  private final Map<String, Results> resultsMap;
  private final Map<String, Long> scenarioNameForReportToCaseIdMap;
  private final TestModuleConfiguration testModuleConfiguration;

  private TestRailClient testRailClient;
  private final CasesDao casesDao;
  private final ResultsDao resultsDao;
  private final RunsDao runsDao;
  private final SectionsDao sectionsDao;
  private final ObjectMapper mapper;

  private long runId;

  public TestRailIntegrationService(TestModuleConfiguration testModuleConfiguration) {
    this.testModuleConfiguration = testModuleConfiguration;
    this.resultsMap = new ConcurrentHashMap<>();
    this.scenarioNameForReportToCaseIdMap = new ConcurrentHashMap<>();

    if(System.getProperty("testrail_projectId") != null) {
      this.projectId = Long.parseLong(System.getProperty("testrail_projectId"));
      this.testRailClient = new TestRailClient();
    }

    mapper = new ObjectMapper();
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    this.casesDao = new CasesDao();
    this.runsDao = new RunsDao();
    this.resultsDao = new ResultsDao();
    this.sectionsDao = new SectionsDao();
  }

  private void setTestRailStatus(ScenarioResult scenarioResult, JsonObject res) {
    if (!scenarioResult.isFailed()) {
      res.put("status_id", TestRailStatus.PASSED.getStatusId());
    } else {
      res.put("status_id", TestRailStatus.FAILED.getStatusId());

      if (scenarioResult.getFailedStep() != null) {
        final StepResult failedStep = scenarioResult.getFailedStep();
        res.put("comment", "This test failed:\n\n\n" + failedStep.getErrorMessage());
      }
    }
  }


  private JsonObject postTestCase(JsonObject data, long sectionId) throws TestRailException {
    return casesDao.addCase(testRailClient, sectionId, data);
  }

  private List<JsonObject> postTestCasesResults(JsonObject resultsForCases)
      throws TestRailException {
    return resultsDao.addResultsForCases(testRailClient, runId, resultsForCases);
  }

  private void postTestRunResults(Results results)  {

    JsonObject resultsForCases = new JsonObject();
    JsonArray resultsArray = new JsonArray();
    resultsForCases.put("results", resultsArray);

    for (ScenarioResult scenarioResult : results.getScenarioResults()) {
      final String nameForReport = scenarioResult.getScenario().getNameForReport();
      final Object testCaseId = scenarioNameForReportToCaseIdMap.get(nameForReport);
      JsonObject res = new JsonObject();
      res.put("case_id", testCaseId);
      setTestRailStatus(scenarioResult, res);
      resultsArray.add(res);
    }

    try {
      List<JsonObject> postedTestCasesResults = postTestCasesResults(resultsForCases);
      logger.debug("Saved test cases results to TestTrails: {}", postedTestCasesResults);

    } catch (TestRailException e) {
      logger.error("Exception in posting results to TestRail \n {}", resultsForCases.encode());
    }
  }

  private void cacheCaseIdToScenarioNameForReport(String nameForReport, Long caseId) {
    scenarioNameForReportToCaseIdMap.put(nameForReport, caseId);
  }

  private void processScenariosInTestSuite(Results results, List<JsonObject> existingTestCases, Long sectionId) {
    JsonObject testCase = new JsonObject();
    final List<ScenarioResult> scenarioResults = results.getScenarioResults();


    for (ScenarioResult sr : scenarioResults) {
      final Scenario scenario = sr.getScenario();

      // Check if test case has been already saved to TestRails
      final Optional<JsonObject> savedTestCase = existingTestCases.stream()
        .filter(exCase -> isExistingCase(exCase, scenario, sectionId))
        .findFirst();
      // If so, remember it in local cache
      if (savedTestCase.isPresent()) {
        cacheCaseIdToScenarioNameForReport(scenario.getNameForReport(), savedTestCase.get().getLong("id"));
        continue;
      }

      testCase.put("title", scenario.getName());
      testCase.put("type_id", 7);
      testCase.put("section_id", sectionId);
      testCase.put("priority_id", 2);
      testCase.put("template_id", "1");
      final String backGroundStepsString = buildSteps(scenario.getFeature().getBackground().getSteps());
      testCase.put("custom_preconds", backGroundStepsString);
      final String stepsString = buildSteps(scenario.getSteps());
      testCase.put("custom_steps", stepsString);

      try {
        JsonObject postedTestCase = postTestCase(testCase, sectionId);
        cacheCaseIdToScenarioNameForReport(scenario.getNameForReport(), postedTestCase.getLong("id"));

        logger.info("POSTED TEST CASE:\n {}", postedTestCase);

      } catch (TestRailException e) {
        e.printStackTrace();
      }
    }
  }

  private String buildSteps(List<Step> steps) {
    return steps.stream().map(Step::toString).collect(Collectors.joining("\n"));
  }


  private boolean isExistingCase(JsonObject exCase, Scenario scenario, Long sectionId) {
    return exCase.getString("title").equals(scenario.getName())
        && exCase.getString("custom_preconds", "").equals(buildSteps(scenario.getFeature().getBackground().getSteps()))
        && exCase.getString("custom_steps", "").equals(buildSteps(scenario.getSteps()))
        && exCase.getLong("section_id", -1L).equals(sectionId);
  }

  private void internalRun(String path, String featureName) {
    Results results = Runner.path(path)
        .tags("~@Ignore", "~@NoTestRail")
        .parallel(1);

    try {
      generateReport(results.getReportDir());
    } catch (IOException ioe) {
      logger.error("Error occurred during feature's report generation: {}", ioe.getMessage());
    }
    resultsMap.put(featureName, results);

    assert results.getFailCount() == 0;
    logger.debug("feature {} run result {} ", path, results.getErrorMessages());
  }

  public void runFeature(String featurePath) {
    if (StringUtils.isBlank(featurePath)) {
      logger.warn("No feature path specified");
      return;
    }
    int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
    internalRun(featurePath, featurePath.substring(++idx));
  }

  public void runFeatureTest(String testFeatureName) {
    if (StringUtils.isBlank(testFeatureName)) {
      logger.warn("No test feature name specified");
      return;
    }
    if (!testFeatureName.endsWith("feature")) {
      testFeatureName = testFeatureName.concat(".feature");
    }
    internalRun(testModuleConfiguration.getBasePath().concat(testFeatureName), testFeatureName);
  }

  public Collection<File> listFiles(Path start) throws IOException {
    return Files.walk(start, Integer.MAX_VALUE)
        .map(Path::toFile)
        .filter(s -> s.getAbsolutePath().endsWith(".json"))
        .collect(Collectors.toList());
  }

  public void generateReport(String karateOutputPath) throws IOException {
    Collection<File> jsonFiles = listFiles(Paths.get(karateOutputPath));
    List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    Configuration config = new Configuration(new File("target"), PROJECT_NAME);
    config.setNotFailingStatuses(Collections.singleton(Status.UNDEFINED));
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);


    jsonPaths.forEach(path->{
      try {
        JsonNode jsonNode = mapper.readTree(new File(path));
        jsonNode.findParents("tags").stream()
            .filter(parent -> parent.get("steps") != null && parent.get("tags").findValue("name").textValue().equals("@Undefined"))
            .forEach(parent -> {
              Optional.ofNullable((ObjectNode) parent.findPath("result"))
                  .ifPresent(result -> result.put("status", "undefined"));
            });

        JsonGenerator generator = mapper.getFactory().createGenerator(new File(path), JsonEncoding.UTF8);
        mapper.writeTree(generator, jsonNode);

      } catch (IOException e) {
        logger.error("Exception in updating statuses for undefined tests", e);
      }
    });

    reportBuilder.generateReports();
  }

  public TestModuleConfiguration getTestConfiguration() {
    return testModuleConfiguration;
  }

  public long createTestRun() {
    try {
      // Create Test Run
      JsonObject newRun = new JsonObject();
      newRun.put("include_all", true);
      SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
      newRun.put("name", testModuleConfiguration.getSuiteName() + " - " + sdf.format(new Date()));
      newRun.put("suite_id", testModuleConfiguration.getSuiteId());

      JsonObject c = runsDao.addRun(testRailClient, projectId, newRun);

      //Extract Test Run Id
      runId = c.getLong(ID);
      return runId;
    } catch (TestRailException e) {
      logger.error("Error occurred during creation of run id");
    }
    return -1;
  }

  public void sendToTestRail() {
    try {
      // get number of cases in suite
      final List<JsonObject> existingTestCases = casesDao.getCases(testRailClient, projectId, testModuleConfiguration.getSuiteId());

      for (Map.Entry<String, Results> featureResults : resultsMap.entrySet()) {
        // extract feature name
        String sectionName = FilenameUtils.getBaseName(featureResults.getKey());

        JsonObject section = getOrCreateSection(sectionName);

        logger.info("Updating cases for {}", featureResults.getKey());
        processScenariosInTestSuite(featureResults.getValue(), existingTestCases, section.getLong("id"));

        logger.info("Posting results for {}", featureResults.getKey());

        postTestRunResults(featureResults.getValue());
      }
    } catch (TestRailException e) {
      logger.error("Error occurred during sending data to TestRail: {} ", e.getMessage());
    }
  }

  private JsonObject getOrCreateSection(String sectionName) throws TestRailException {
   List<JsonObject> sections =  sectionsDao.getSections(testRailClient, projectId, testModuleConfiguration.getSuiteId());
   JsonObject existingSection = sections.stream()
     .filter(section -> section.getString("name").equals(sectionName)
         && section.getLong("parent_id").equals(testModuleConfiguration.getSectionId()))
     .findFirst()
     .orElse(null);
   if (existingSection!= null) {
     return existingSection;
   }
   else {
     JsonObject newSection = new JsonObject();
     newSection.put("name", sectionName);
     newSection.put("parent_id", testModuleConfiguration.getSectionId());
     newSection.put("suite_id", testModuleConfiguration.getSuiteId());
     return sectionsDao.addSection(testRailClient, projectId, newSection);
   }
  }

  public void addResult(String testName, Results results) {
    resultsMap.put(testName, results);
  }

  public void closeRun(Long runId) {
    try {
      runsDao.closeRun(testRailClient, runId);
    } catch (TestRailException e) {
      e.printStackTrace();
    }
  }
}
