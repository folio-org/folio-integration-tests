package org.folio.testrail;

import static org.folio.TestUtils.runHook;

import com.gurock.testrail.APIClient;
import com.gurock.testrail.APIException;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.StringUtils;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractTestRailIntegrationTest {

  protected static final Logger logger = LoggerFactory
      .getLogger(AbstractTestRailIntegrationTest.class);

  protected static Long runId;
  protected static Long suiteId;
  protected static Long sectionId;
  protected static String projectId;
  protected static String testSuiteName;
  protected static final boolean refreshScenarios = false;
  protected static final Map<String, Results> resultsMap = new ConcurrentHashMap<>();

  private static APIClient client;
  private String basePath;

  public AbstractTestRailIntegrationTest(String basePath, String suitName, Long suitId,
      Long sectionId) {
    this.basePath = basePath;
    this.testSuiteName = suitName;
    this.suiteId = suitId;
    this.sectionId = sectionId;
  }


  private static void setTestRailStatus(ScenarioResult scenarioResult, JSONObject res) {
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

  private static void deleteScenarios(JSONArray o) throws IOException, APIException {
    for (Object o1 : o) {
      System.out.println("s = " + o1);
      final Object id = ((JSONObject) o1).get("id");
      deleteTestCase(id);
    }
  }

  private static void deleteTestCase(Object id) throws IOException, APIException {
    client.sendPost("delete_case/" + id, new JSONObject());
  }

  private static JSONObject postScenario(Map data) throws IOException, APIException {
    return (JSONObject) client.sendPost("add_case/" + sectionId, data);
  }

  private static void postTestRunResults(Results results) throws IOException, APIException {

    JSONArray c1 = (JSONArray) client.sendGet("get_tests/" + runId);
    System.out.println("tests in run " + c1);
    Map testIdsMap = new HashMap();
    for (Object o1 : c1) {
      if (o1 instanceof JSONObject) {
        JSONObject jsonObject = (JSONObject) o1;
        testIdsMap.put(jsonObject.get("title"), jsonObject.get("id"));

      }
    }
    final Object title2CaseIdMap = c1.stream().collect(
        Collectors.toMap(a -> ((JSONObject) a).get("title"), a -> ((JSONObject) a).get("case_id")));
    JSONObject resultsForCases = new JSONObject();
    JSONArray resultsArray = new JSONArray();
    resultsForCases.put("results", resultsArray);

    final List<ScenarioResult> scenarioResults = results.getScenarioResults();
    if (title2CaseIdMap instanceof Map) {
      Map map = (Map) title2CaseIdMap;
      for (ScenarioResult scenarioResult : scenarioResults) {
        final String name = scenarioResult.getScenario().getName();
        final Object testCaseId = map.get(name);
        JSONObject res = new JSONObject();
        res.put("case_id", testCaseId);
        setTestRailStatus(scenarioResult, res);
        resultsArray.add(res);

      }
      try {
        client.sendPost("add_results_for_cases/" + runId, resultsForCases);
      } catch (APIException e) {
        System.out.println("Exception in posting results to TestRail " + e.getMessage());
        System.out.println("@@resultsForCases@@: " + resultsForCases.toJSONString());
      }
    }
  }

  private static void updateScenariosInTestSuite(Results results, JSONArray scenarios)
      throws IOException, APIException {
    Map data = new HashMap();
    final List<ScenarioResult> scenarioResults = results.getScenarioResults();
    for (ScenarioResult sr : scenarioResults) {
      final Scenario scenario = sr.getScenario();
      final String nameForReport = scenario.getName();
      final Optional title = scenarios.stream().map(a -> ((JSONObject) a).get("title"))
          .filter(a -> a.equals(nameForReport)).findFirst();
      if (title.isPresent()) {
        continue;
      }
      data.put("title", nameForReport);
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
        JSONObject resp = postScenario(data);
        System.out.println("POSTED TEST CASES: " + resp);
      } catch (IOException | APIException e) {
        e.printStackTrace();
      }
    }
  }

  protected static Collection<File> listFiles(Path start) throws IOException {
    return Files.walk(start, Integer.MAX_VALUE)
        .map(Path::toFile)
        .filter(s -> s.getAbsolutePath().endsWith(".json"))
        .collect(Collectors.toList());
  }

  protected static void generateReport(String karateOutputPath) throws IOException {
    Collection<File> jsonFiles = listFiles(Paths.get(karateOutputPath));
    List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    Configuration config = new Configuration(new File("target"), "gulfstream");
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
    reportBuilder.generateReports();
  }


  protected static boolean isTestRailIntegrationEnabled() {
    boolean isTestRailsEnabled = System.getProperty("testrail_url") != null;
    logger.debug("TestRails integration status, isTestRailsEnabled: {}", isTestRailsEnabled);
    return isTestRailsEnabled;
  }

  private static void internalRun(String path, String featureName) {
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

  protected static void runFeature(String featurePath) {
    if (StringUtils.isBlank(featurePath)) {
      logger.warn("No feature path specified");
      return;
    }
    int idx = Math.max(featurePath.lastIndexOf("/"), featurePath.lastIndexOf("\\"));
    internalRun(featurePath, featurePath.substring(++idx));
  }

  protected void runFeatureTest(String testFeatureName) {
    if (StringUtils.isBlank(testFeatureName)) {
      logger.warn("No test feature name specified");
      return;
    }
    if (!testFeatureName.endsWith("feature")) {
      testFeatureName = testFeatureName.concat(".feature");
    }
    internalRun(basePath.concat(testFeatureName), testFeatureName);
  }

  @BeforeAll
  public static void beforeAll() {
    runHook();
    try {
      if (isTestRailIntegrationEnabled()) {
        client = new APIClient(System.getProperty("testrail_url"));
        client.setUser(System.getProperty("testrail_userId"));
        client.setPassword(System.getProperty("testrail_pwd"));
        projectId = System.getProperty("testrail_projectId");
        //Create Test Run
        Map data = new HashMap();
        data.put("include_all", true);
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
        data.put("name", testSuiteName + " - " + sdf.format(new Date()));
        data.put("suite_id", suiteId);
        JSONObject c = (JSONObject) client.sendPost("add_run/" + projectId, data);
        //Extract Test Run Id
        runId = (Long) c.get("id");
        System.out.println("runId = " + runId);
      }
    } catch (IOException | APIException e) {
      System.out.println("************TEST RAIL INTEGRATION DISABLED****************");
    }
  }

  @AfterAll
  public static void afterAll() throws IOException, APIException {
    if (isTestRailIntegrationEnabled()) {
      //get number of cases in suite
      final JSONArray existingScenarios = (JSONArray) client
          .sendGet("get_cases/" + projectId + "&suite_id=" + suiteId);
      if (existingScenarios.size() == 0 || refreshScenarios) {
        System.out.println("===REFRESHING TEST SCENARIOS===");
        deleteScenarios(existingScenarios);
      }

      for (Map.Entry<String, Results> results : resultsMap.entrySet()) {
        System.out.printf("Updating cases for %s\n", results.getKey());
        updateScenariosInTestSuite(results.getValue(), existingScenarios);
        System.out.printf("Posting results for %s:\n", results.getKey());
        postTestRunResults(results.getValue());
      }
    }
  }

}