package org.folio.testrail.dao;

import java.util.List;

import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;

import io.vertx.core.json.JsonObject;

public class ResultsDao {

  public static final String API_METHOD_ADD_RESULTS_FOR_CASES = "add_results_for_cases/";

  public List<JsonObject> addResultsForCases(TestRailClient testRailClient, long runId, JsonObject newResult) throws TestRailException {
    return testRailClient.postCollectionResponse(API_METHOD_ADD_RESULTS_FOR_CASES + runId, newResult);
  }

}
