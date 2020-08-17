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
import java.util.Properties;
import java.util.stream.Collectors;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
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
    private static String testSuiteName = "mod-oai-pmh";
    private static boolean refreshScenarios = false;
    private static boolean testRailIntegrationEnabled = System.getProperty("testrail_url") != null;


    @Test
    void oaiPmhbasicTests() throws IOException, APIException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-basic.feature")
                .tags("~@Ignore", "~@NoTestRail")
                .parallel(1);
        generateReport(results.getReportDir());

        if (testRailIntegrationEnabled){
            postTestCases(results);
        }

        assert results.getFailCount() == 0;
    }

    @Test
    void oaiPmhEnhancementTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-enhancement.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
        assert results.getFailCount() == 0;
    }

    @Test
    void oaiPmhMarWithHoldingsTests() throws IOException {
        Results results = Runner.path("classpath:domain/oaipmh/oaipmh-q3-marc_withholdings.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
        assert results.getFailCount() == 0;
    }

    @Test
    void loadDefaultConfigurationTests() throws IOException {
        Results results = Runner.path("classpath:domain/mod-configuration/load-default-pmh-configuration.feature.feature")
                .tags("~@Ignore")
                .parallel(1);
        generateReport(results.getReportDir());
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

    private static void postTestCases(Results results) throws IOException, APIException {
        //get number of cases in suite
        final JSONArray o = (JSONArray) client.sendGet("get_cases/" + projectId + "&suite_id=" + suite_id);

        Map data = new HashMap();
        final List<ScenarioResult> scenarioResults = results.getScenarioResults();
        if (o.size() == 0 || refreshScenarios) {
            deleteScenarios(o);
            scenarioResults.forEach(sr -> {
                final Scenario scenario = sr.getScenario();
                final String nameForReport = scenario.getName();
                data.put("title", nameForReport);
                data.put("type_id", 7);
                data.put("priority_id", 2);
                data.put("template_id", "1");
                final String backGroundStepsString = scenario.getFeature().getBackground().getSteps().stream().map(Step::toString).collect(Collectors.joining("\n"));
                data.put("custom_preconds", backGroundStepsString);
                final String stepsString = scenario.getSteps().stream().map(Step::toString).collect(Collectors.joining("\n"));
                data.put("custom_steps", stepsString);
                try {
                    JSONObject c = postScenario(data);
                    System.out.println("RESULTS = " + c);
                } catch (IOException | APIException e) {
                    e.printStackTrace();
                }
            });
        }

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
            client.sendPost("add_results_for_cases/" + runId, resultsForCases);
        }
    }

    private static void setTestRailStatus(ScenarioResult scenarioResult, JSONObject res) {
        if (!scenarioResult.isFailed()){
            res.put("status_id", TestRailStatus.PASSED.getStatusId());
        }else{
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
        //todo
        if ((Long) id != 11150) {
            client.sendPost("delete_case/" + id, new JSONObject());
        }
    }

    private static JSONObject postScenario(Map data) throws IOException, APIException {
        return (JSONObject) client.sendPost("add_case/" + section_id, data);
    }


    @BeforeAll
    public static void beforeAll(){
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
//                final Object o = client.sendGet("get_suite/" + suite_id);
//                System.out.println("o = " + o);

            }
        } catch (IOException | APIException e) {
            System.out.println("************TEST RAIL INTEGRATION DISABLED****************");
        }

    }

    @AfterAll
    public static void afterAll() throws IOException, APIException {
        if (testRailIntegrationEnabled) {
            JSONObject c = (JSONObject) client.sendPost("close_run/" + runId, new JSONObject());
//            System.out.println("closerun = " + c);
        }

//        final JSONObject data = new JSONObject();
//        data.put("is_completed", "true");
//        data.put("completed_on", new Date());
//        JSONObject c = (JSONObject)client.sendPost("update_run/" + runId, data);
//        System.out.println("closerun = " + c);

    }




}
