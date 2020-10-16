package org.folio.testrail;

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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestRailIntegrationHelper {

  private static final Logger logger = LoggerFactory.getLogger(TestRailIntegrationHelper.class);
  private static final String PROJECT_NAME = "ThunderJet";

  private APIClient client;
  private String projectId;
  private long runId;
  private Map<String, Results> resultsMap;
  private TestConfigurationEnum testConfiguration;

  public TestRailIntegrationHelper(TestConfigurationEnum testConfiguration) {
    this.testConfiguration = testConfiguration;
    resultsMap = new ConcurrentHashMap<>();
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
      final Object id = ((JSONObject) o1).get("id");
      deleteTestCase(id);
    }
  }

  private void deleteTestCase(Object id) throws IOException, APIException {
    client.sendPost("delete_case/" + id, new JSONObject());
  }

  private JSONObject postScenario(Map data) throws IOException, APIException {
    return (JSONObject) client.sendPost("add_case/" + testConfiguration.getSectionId(), data);
  }

  private void postTestRunResults(Results results) throws IOException, APIException {
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
        Collectors.toMap(
            a -> String.format("%s_%s", ((JSONObject) a).get("title"), ((JSONObject) a).get("id")),
            a -> ((JSONObject) a).get("case_id")));

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

  private void updateScenariosInTestSuite(Results results, JSONArray scenarios)
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
    projectId = System.getProperty("testrail_projectId");
  }

  public long createTestRun() {
    try {
      //Create Test Run
      Map data = new HashMap();
      data.put("include_all", true);
      SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
      data.put("name", testConfiguration.getSuiteName() + " - " + sdf.format(new Date()));
      data.put("suite_id", testConfiguration.getSuiteId());
      JSONObject c = (JSONObject) client.sendPost("add_run/" + projectId, data);

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
      final JSONArray existingScenarios = (JSONArray) client
          .sendGet("get_cases/" + projectId + "&suite_id=" + testConfiguration.getSuiteId());
      if (existingScenarios.size() == 0 || isRefreshScenarios) {
        System.out.println("===REFRESHING TEST SCENARIOS===");
        deleteScenarios(existingScenarios);
      }

      for (Map.Entry<String, Results> results : resultsMap.entrySet()) {
        System.out.printf("Updating cases for %s\n", results.getKey());
        updateScenariosInTestSuite(results.getValue(), existingScenarios);
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
