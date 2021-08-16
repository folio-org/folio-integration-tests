package org.folio;

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

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import com.gurock.testrail.APIClient;
import com.gurock.testrail.APIException;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.core.Scenario;
import com.intuit.karate.core.ScenarioResult;
import com.intuit.karate.core.Step;
import com.intuit.karate.core.StepResult;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

class ModOaiPmhTests {

    private static APIClient client;
    private static Long runId;
    private static Long suite_id = 49l;
    private static Long section_id = 1327l;
    private static String projectId;
    private static final String testSuiteName = "mod-oai-pmh";
    private static final boolean refreshScenarios = false;
    private static final boolean testRailIntegrationEnabled = System.getProperty("testrail_url") != null;
    private static final Map<String, Results> resultsMap = new ConcurrentHashMap<>();

    @Test
    void oaiPmhbasicTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-basic.feature")
                .tags("~@Ignore", "~@NoTestRail")
                .parallel(1);
        generateReport(results.getReportDir());

        resultsMap.put("oaipmh-basic", results);

        assert results.getFailCount() == 0;
    }

    @Test
    void oaiPmhEnhancementTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-enhancement.feature")
                .tags("~@Ignore", "~@NoTestRail")
                .parallel(1);
        generateReport(results.getReportDir());

        resultsMap.put("oaipmh-enhancement", results);

        assert results.getFailCount() == 0;
    }

    @Disabled("Disabled until the records retrieving within verbs like ListRecords and listIdentifiers " +
            "will be switched to use the inventory storage + generate marc utils on the fly library instead of SRS only")
    @Test
    void oaiPmhMarWithHoldingsTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-q3-marc_withholdings.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());

        resultsMap.put("oaipmh-q3-marc_withholdings", results);

        assert results.getFailCount() == 0;
    }

    @Test
    void oaiPmhSetsTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/sets.feature")
                .tags("~@Ignore", "~@NoTestRail")
                .parallel(1);
        generateReport(results.getReportDir());

        resultsMap.put("sets", results);

        assert results.getFailCount() == 0;
    }

    @Test
    void loadDefaultConfigurationTests() throws IOException {
        Results results = Runner.path("classpath:domain/mod-configuration/load-default-pmh-configuration.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());

        resultsMap.put("load-default-pmh-configuration", results);

        assert results.getFailCount() == 0;
    }


    static void generateReport(String karateOutputPath) throws IOException {
        Collection<File> jsonFiles = listFiles(Paths.get(karateOutputPath));
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "gulfstream");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

    static Collection<File> listFiles(Path start) throws IOException {
        return Files.walk(start, Integer.MAX_VALUE)
                .map(Path::toFile)
                .filter(s -> s.getAbsolutePath().endsWith(".json"))
                .collect(Collectors.toList());
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

        final List<ScenarioResult> scenarioResults = results.getScenarioResults().collect(Collectors.toList());
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
        return (JSONObject) client.sendPost("add_case/" + section_id, data);
    }


    @BeforeAll
    public static void beforeAll() {
        try {
            if (testRailIntegrationEnabled) {
                client = new APIClient(System.getProperty("testrail_url"));
                client.setUser(System.getProperty("testrail_userId"));
                client.setPassword(System.getProperty("testrail_pwd"));
                projectId = System.getProperty("testrail_projectId");
                //Create Test Run
                Map data = new HashMap();
                data.put("include_all", true);
                SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
                data.put("name", testSuiteName + " - " + sdf.format(new Date()));
                data.put("suite_id", suite_id);
                JSONObject c = (JSONObject) client.sendPost("add_run/" + projectId, data);
                //Extract Test Run Id
                runId = (Long) c.get("id");
                System.out.println("runId = " + runId);
            }
        } catch (IOException | APIException e) {
            System.out.println("************TEST RAIL INTEGRATION DISABLED****************");
        }
    }

    private static void updateScenariosInTestSuite(Results results, JSONArray scenarios) throws IOException, APIException {
        Map data = new HashMap();
        final List<ScenarioResult> scenarioResults = results.getScenarioResults().collect(Collectors.toList());
        for (ScenarioResult sr : scenarioResults) {
            final Scenario scenario = sr.getScenario();
            final String nameForReport = scenario.getName();
            final Optional title = scenarios.stream().map(a -> ((JSONObject) a).get("title")).filter(a -> a.equals(nameForReport)).findFirst();
            if (title.isPresent()) {
                continue;
            }
            data.put("title", nameForReport);
            data.put("type_id", 7);
            data.put("priority_id", 2);
            data.put("template_id", "1");
            final String backGroundStepsString = scenario.getFeature().getBackground().getSteps().stream().map(Step::toString).collect(Collectors.joining("\n"));
            data.put("custom_preconds", backGroundStepsString);
            final String stepsString = scenario.getSteps().stream().map(Step::toString).collect(Collectors.joining("\n"));
            data.put("custom_steps", stepsString);
            try {
                JSONObject resp = postScenario(data);
                System.out.println("POSTED TEST CASES: " + resp);
            } catch (IOException | APIException e) {
                e.printStackTrace();
            }
        }
    }

    @AfterAll
    public static void afterAll() throws IOException, APIException {
        if (testRailIntegrationEnabled) {
            //get number of cases in suite
            final JSONArray existingScenarios = (JSONArray) client.sendGet("get_cases/" + projectId + "&suite_id=" + suite_id);
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
//            JSONObject c = (JSONObject) client.sendPost("close_run/" + runId, new JSONObject());
//            System.out.println("closerun = " + c);
        }

//        final JSONObject data = new JSONObject();
//        data.put("is_completed", "true");
//        data.put("completed_on", new Date());
//        JSONObject c = (JSONObject)client.sendPost("update_run/" + runId, data);
//        System.out.println("closerun = " + c);

    }
}
