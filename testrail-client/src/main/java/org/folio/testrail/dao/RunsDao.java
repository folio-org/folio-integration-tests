package org.folio.testrail.dao;

import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;

import io.vertx.core.json.JsonObject;

public class RunsDao {
  public static final String API_METHOD_ADD_RUN = "add_run/";
  public static final String API_METHOD_CLOSE_RUN = "close_run/";

  public JsonObject addRun(TestRailClient testRailClient, long projectId, JsonObject data) throws TestRailException {
    return testRailClient.post(API_METHOD_ADD_RUN + projectId, data);
  }

  public void closeRun(TestRailClient testRailClient, long runId) throws TestRailException {
     testRailClient.post(API_METHOD_CLOSE_RUN + runId, new JsonObject());
  }
}
