package org.folio.test.dao;

import java.util.List;

import org.folio.test.config.TestRailClient;
import org.folio.test.models.AddResultsForCasesRequest;
import org.folio.test.models.AddResultsForCasesResponse;
import org.folio.test.models.Tests;
import org.springframework.core.ParameterizedTypeReference;

public class TestRailDao {

  public static final String GET_TESTS = "get_tests/";
  public static final String ADD_RESULTS_FOR_CASES = "add_results_for_cases/";

  public Tests getTests(TestRailClient testRailClient, int runId, int offset, int limit) {
    var typeReference = new ParameterizedTypeReference<Tests>() {};
    return testRailClient.get(GET_TESTS + runId + "&offset=" + offset + "&limit=" + limit, typeReference);
  }

  public List<AddResultsForCasesResponse> addResultsForCases(TestRailClient testRailClient, int runId, AddResultsForCasesRequest requestPayload) {
    var typeReference = new ParameterizedTypeReference<List<AddResultsForCasesResponse>>() {};
    return testRailClient.post(ADD_RESULTS_FOR_CASES + runId, requestPayload, typeReference);
  }
}
