package org.folio.testrail.dao;

import java.util.List;

import io.vertx.core.json.JsonObject;
import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;

public class TestsDao {

  public static final String API_METHOD_GET_TESTS = "get_tests/";

  public List<JsonObject> getTests(TestRailClient client, long runId) throws TestRailException {
    return client.getCollection(API_METHOD_GET_TESTS + runId);
  }
}
