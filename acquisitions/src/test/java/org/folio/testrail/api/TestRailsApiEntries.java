package org.folio.testrail.api;

import io.netty.karate.handler.codec.http.HttpMethod;
import java.io.IOException;
import org.json.simple.JSONArray;
import org.json.simple.JSONAware;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestRailsApiEntries {

  protected static final Logger logger = LoggerFactory
      .getLogger(TestRailsApiEntries.class);

  // Name constants of CasesApiEnum
  private static final String CASES_API_NAME_GET_CASES = "get_cases";
  private static final String CASES_API_NAME_ADD_CASE = "add_case";
  private static final String CASES_API_NAME_DELETE_CASE = "delete_case";

  // Name constants of ResultsApiEnum
  private static final String RESULTS_API_NAME_ADD_RESULTS_FOR_CASES = "add_results_for_cases";

  // Name constants of TestsApiEnum
  private static final String TESTS_API_NAME_GET_TESTS = "get_tests";

  // Name constants of RunsApiEnum
  private static final String RUNS_API_NAME_ADD_RUN = "add_run";

  /**
   * API:Cases https://www.gurock.com/testrail/docs/api/reference/cases
   */
  public enum CasesApiEnum implements CasesApiEntry {
    // Returns a list of test cases for a project or specific test suite
    GET_CASES_API_ENTRY(CASES_API_NAME_GET_CASES, "get_cases/",
        HttpMethod.GET) {
      @Override
      public JSONArray getCases(APIClient client, long projectId, long suiteId)
          throws IOException, APIException {
        return (JSONArray) client.sendGet(getUrl() + projectId + "&suite_id=" + suiteId);
      }

      @Override
      public JSONObject addCase(APIClient client, long sectionId, JSONObject data) {
        return notImplemented();
      }

      @Override
      public void deleteCase(APIClient client, long caseId) {
        notImplemented();
      }
    },

    // // Creates a new test case.
    ADD_CASE_API_ENTRY(CASES_API_NAME_ADD_CASE, "add_case/", HttpMethod.POST) {
      @Override
      public JSONArray getCases(APIClient client, long projectId, long suiteId) {
        return notImplemented();
      }

      @Override
      public JSONObject addCase(APIClient client, long sectionId, JSONObject data)
          throws IOException, APIException {
        return (JSONObject) client.sendPost(getUrl() + sectionId, data);
      }

      @Override
      public void deleteCase(APIClient client, long caseId) {
        notImplemented();
      }
    },

    // Deletes an existing test case.
    DELETE_CASE_API_ENTRY(CASES_API_NAME_DELETE_CASE, "delete_case/{case_id}", HttpMethod.POST) {
      @Override
      public JSONArray getCases(APIClient client, long projectId, long suiteId) {
        return notImplemented();
      }

      @Override
      public JSONObject addCase(APIClient client, long sectionId, JSONObject data) {
        return notImplemented();
      }

      @Override
      public void deleteCase(APIClient client, long caseId) throws IOException, APIException {
        client.sendPost("delete_case/" + caseId, getEmptyJson());
      }
    };

    private ApiEntryHolder apiHolder;

    CasesApiEnum(String name, String url, HttpMethod method) {
      apiHolder = new ApiEntryHolder(name, url, method);
    }

    @Override
    public ApiEntry getHolder() {
      return apiHolder;
    }

  }

  /**
   * API:Results https://www.gurock.com/testrail/docs/api/reference/results
   */
  public enum ResultsApiEnum implements ResultsApiEntry {
    // Adds one or more new test results
    ADD_RESULTS_FOR_CASES_API_ENTRY(RESULTS_API_NAME_ADD_RESULTS_FOR_CASES,
        "add_results_for_cases/",
        HttpMethod.POST);

    private ApiEntryHolder apiHolder;

    ResultsApiEnum(String name, String url, HttpMethod method) {
      apiHolder = new ApiEntryHolder(name, url, method);
    }

    @Override
    public ApiEntry getHolder() {
      return apiHolder;
    }

    @Override
    public JSONArray addResultsForCases(APIClient client, long runId, JSONObject resultsForCases)
        throws IOException, APIException {
      return (JSONArray) client.sendPost(getUrl() + runId, resultsForCases);
    }

  }

  /**
   * API:Tests https://www.gurock.com/testrail/docs/api/reference/tests
   */
  public enum TestsApiEnum implements TestsApiEntry {
    // Returns a list of tests for a test run
    GET_TESTS_API_ENTRY(TESTS_API_NAME_GET_TESTS, "get_tests/", HttpMethod.GET);

    private ApiEntryHolder apiHolder;

    TestsApiEnum(String name, String url, HttpMethod method) {
      apiHolder = new ApiEntryHolder(name, url, method);
    }

    @Override
    public ApiEntry getHolder() {
      return apiHolder;
    }

    @Override
    public JSONArray getTests(APIClient client, long runId) throws IOException, APIException {
      return (JSONArray) client.sendGet(getUrl() + runId);
    }

  }

  /**
   * API:Runs https://www.gurock.com/testrail/docs/api/reference/runs
   */
  public enum RunsApiEnum implements RunsApiEntry {
    // Creates a new test run.
    ADD_RUN_API_ENTRY(RUNS_API_NAME_ADD_RUN, "add_run/", HttpMethod.POST);

    private ApiEntryHolder apiHolder;

    RunsApiEnum(String name, String url, HttpMethod method) {
      apiHolder = new ApiEntryHolder(name, url, method);
    }

    @Override
    public ApiEntry getHolder() {
      return apiHolder;
    }

    @Override
    public JSONObject addRun(APIClient client, long projectId, JSONObject data)
        throws IOException, APIException {
      return (JSONObject) client.sendPost(getUrl() + projectId, data);
    }

  }

  private static <T extends JSONAware> T notImplemented() {
    throw new IllegalStateException("Method not implemented");
  }

  private static JSONObject getEmptyJson() {
    return new JSONObject();
  }

}
