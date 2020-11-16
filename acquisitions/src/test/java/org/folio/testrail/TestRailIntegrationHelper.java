package org.folio.testrail;

import org.folio.testrail.api.APIClient;
import org.folio.testrail.api.APIException;
import org.folio.testrail.api.TestRailsApiEntries.CasesApiEnum;
import org.folio.testrail.api.TestRailsApiEntries.ResultsApiEnum;
import org.folio.testrail.api.TestRailsApiEntries.RunsApiEnum;
import org.folio.testrail.api.TestRailsApiEntries.TestsApiEnum;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.core.Scenario;
import com.intuit.karate.core.ScenarioResult;
import com.intuit.karate.core.Step;
import com.intuit.karate.core.StepResult;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.lang3.StringUtils;
import org.folio.testrail.config.TestConfigurationEnum;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestRailIntegrationHelper {

  private static final Logger logger = LoggerFactory.getLogger(TestRailIntegrationHelper.class);
  private static final String PROJECT_NAME = "ThunderJet";

  private APIClient client;
  private long projectId;
  private long runId;
  private Map<String, Results> resultsMap;
  private Map<String, Long> scenarioNameForReportToCaseIdMap;
  private TestConfigurationEnum testConfiguration;

  public TestRailIntegrationHelper(TestConfigurationEnum testConfiguration) {
    this.testConfiguration = testConfiguration;
    resultsMap = new ConcurrentHashMap<>();
    scenarioNameForReportToCaseIdMap = new ConcurrentHashMap<>();
  }

  private void setTestRailStatus(ScenarioResult scenarioResult, JSONObject res) {
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

  private void deleteScenarios(JSONArray o) throws IOException, APIException {
    for (Object o1 : o) {
      System.out.println("s = " + o1);
      final long id = getJsonField(o1, "id");
      deleteTestCase(id);
    }
  }

  private void deleteTestCase(long id) throws IOException, APIException {
    CasesApiEnum.DELETE_CASE_API_ENTRY.deleteCase(client, id);
  }

  private JSONObject postTestCase(JSONObject data) throws IOException, APIException {
    return CasesApiEnum.ADD_CASE_API_ENTRY.addCase(client, testConfiguration.getSectionId(), data);
  }

  private JSONArray postTestCasesResults(JSONObject resultsForCases)
      throws IOException, APIException {
    return ResultsApiEnum.ADD_RESULTS_FOR_CASES_API_ENTRY
        .addResultsForCases(client, runId, resultsForCases);
  }

  private <T> T getJsonField(Object obj, String fieldName) {
    if (obj instanceof JSONObject && StringUtils.isNoneBlank(fieldName)) {
      return (T) ((JSONObject) obj).get(fieldName);
    }
    return null;
  }

  private void postTestRunResults(Results results) throws IOException, APIException {
    // Here remains for debugging purposes only
    List<JSONObject> c1 = TestsApiEnum.GET_TESTS_API_ENTRY.getTests(client, runId);

    System.out.println("\nTests in run:\n" + c1);

    JSONObject resultsForCases = new JSONObject();
    JSONArray resultsArray = new JSONArray();
    resultsForCases.put("results", resultsArray);

    for (ScenarioResult scenarioResult : results.getScenarioResults()) {
      final String nameForReport = scenarioResult.getScenario().getNameForReport();
      final Object testCaseId = scenarioNameForReportToCaseIdMap.get(nameForReport);
      JSONObject res = new JSONObject();
      res.put("case_id", testCaseId);
      setTestRailStatus(scenarioResult, res);
      resultsArray.add(res);
    }

    try {
      JSONArray postedTestCasesResults = postTestCasesResults(resultsForCases);
      logger.debug("Saved test cases results to TestTrails: {}", postedTestCasesResults);

    } catch (APIException e) {
      System.out.println("Exception in posting results to TestRail " + e.getMessage());
      System.out.println("@@resultsForCases@@: " + resultsForCases.toJSONString());
    }
  }

  private void cacheCaseIdToScenarioNameForReport(String nameForReport, Long caseId) {
    scenarioNameForReportToCaseIdMap.put(nameForReport, caseId);
  }

  private void updateScenariosInTestSuite(Results results, JSONArray existingTestCases) {
    JSONObject data = new JSONObject();
    final List<ScenarioResult> scenarioResults = results.getScenarioResults();
    for (ScenarioResult sr : scenarioResults) {
      final Scenario scenario = sr.getScenario();
      final String scenarioName = scenario.getName();

      // Check if test case has been already saved to TestRails
      final Optional<JSONObject> savedTestCase = existingTestCases.stream()
          .filter(e -> getJsonField(e, "title").equals(scenarioName)).findFirst();
      // If so, remember it in local cache
      if (savedTestCase.isPresent()) {
        cacheCaseIdToScenarioNameForReport(scenario.getNameForReport(),
            getJsonField(savedTestCase.get(), "id"));
        continue;
      }

      data.put("title", scenarioName);
      data.put("type_id", 7);
      data.put("priority_id", 2);
      data.put("template_id", "1");
      final String backGroundStepsString = scenario.getFeature().getBackground().getSteps().stream()
          .map(
              Step::toString).collect(Collectors.joining("\n"));
      data.put("custom_preconds", backGroundStepsString);
      final String stepsString = scenario.getSteps().stream().map(Step::toString)
          .collect(Collectors.joining("\n"));
      data.put("custom_steps", stepsString);
      try {
        JSONObject postedTestCase = postTestCase(data);
        cacheCaseIdToScenarioNameForReport(scenario.getNameForReport(),
            getJsonField(postedTestCase, "id"));
        System.out.println("POSTED TEST CASE:\n" + postedTestCase);
      } catch (IOException | APIException e) {
        e.printStackTrace();
      }
    }
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
    internalRun(testConfiguration.getBasePath().concat(testFeatureName), testFeatureName);
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
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
    reportBuilder.generateReports();
  }

  public boolean isTestRailIntegrationEnabled() {
    boolean isTestRailsEnabled = System.getProperty("testrail_url") != null;
    logger.debug("TestRails integration status, isTestRailsEnabled: {}", isTestRailsEnabled);
    return isTestRailsEnabled;
  }

  public TestConfigurationEnum getTestConfiguration() {
    return testConfiguration;
  }

  public void initConnection() {
    client = new APIClient(System.getProperty("testrail_url"));
    client.setUser(System.getProperty("testrail_userId"));
    client.setPassword(System.getProperty("testrail_pwd"));
    projectId = Long.parseLong(System.getProperty("testrail_projectId"));
  }

  public long createTestRun() {
    try {
      //Create Test Run
      JSONObject data = new JSONObject();
      data.put("include_all", true);
      SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
      data.put("name", testConfiguration.getSuiteName() + " - " + sdf.format(new Date()));
      data.put("suite_id", testConfiguration.getSuiteId());
      JSONObject c = RunsApiEnum.ADD_RUN_API_ENTRY.addRun(client, projectId, data);

      //Extract Test Run Id
      runId = (Long) c.get("id");
      return runId;
    } catch (IOException | APIException e) {
      logger.error("Error occurred during creation of run id");
    }
    return -1;
  }

  public void sendToTestTrails(boolean isRefreshScenarios) {
    try {
      //get number of cases in suite
      final JSONArray existingTestCases = CasesApiEnum.GET_CASES_API_ENTRY
          .getCases(client, projectId, testConfiguration.getSuiteId());

      if (existingTestCases.size() == 0 || isRefreshScenarios) {
        System.out.println("===REFRESHING TEST SCENARIOS===");
        deleteScenarios(existingTestCases);
      }

      for (Map.Entry<String, Results> results : resultsMap.entrySet()) {
        System.out.printf("Updating cases for %s\n", results.getKey());
        updateScenariosInTestSuite(results.getValue(), existingTestCases);

        System.out.printf("Posting results for %s:\n", results.getKey());
        postTestRunResults(results.getValue());
      }
    } catch (APIException | IOException e) {
      logger.error("Error occurred during sending data to TestRail:", e.getMessage());
    }
  }

  public void addResult(String testName, Results results) {
    resultsMap.put(testName, results);
  }

}
