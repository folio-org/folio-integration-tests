package org.folio.testrail.dao;

import java.util.List;

import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;

import io.vertx.core.json.JsonObject;

public class CasesDao {
  private static final String API_METHOD_GET_CASES = "get_cases/";
  private static final String API_METHOD_ADD_CASE = "add_case/";
  private static final String API_METHOD_DELETE_CASE = "delete_case/";

  public List<JsonObject> getCases(TestRailClient testRailClient, long projectId, long suiteId) throws TestRailException {
    return testRailClient.getCollection(API_METHOD_GET_CASES + projectId + "&suite_id=" + suiteId);
  }

  public JsonObject addCase(TestRailClient testRailClient, long sectionId, JsonObject data) throws TestRailException {
    return testRailClient.post(API_METHOD_ADD_CASE + sectionId, data);
  }

  public void deleteCase(TestRailClient testRailClient, long caseId) throws TestRailException {
    testRailClient.post(API_METHOD_DELETE_CASE + caseId, new JsonObject());
  }

}
