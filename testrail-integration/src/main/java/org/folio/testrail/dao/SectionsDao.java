package org.folio.testrail.dao;

import java.util.List;

import org.folio.testrail.api.TestRailClient;
import org.folio.testrail.api.TestRailException;

import io.vertx.core.json.JsonObject;

public class SectionsDao {

  public static final String API_METHOD_GET_SECTIONS = "get_sections/";
  public static final String API_METHOD_GET_SECTION = "get_section/";
  public static final String API_METHOD_ADD_SECTION = "add_section/";
  public static final String API_METHOD_UPDATE_SECTION = "update_section";
  public static final String API_METHOD_DELETE_SECTION = "delete_section/";

  public List<JsonObject> getSections(TestRailClient testRailClient, long projectId, long suiteId) throws TestRailException {
    return testRailClient.getCollection(API_METHOD_GET_SECTIONS + projectId + "&suite_id=" + suiteId);
  }

  public JsonObject getSection(TestRailClient testRailClient, long sectionId) throws TestRailException {
    return testRailClient.get(API_METHOD_GET_SECTION + sectionId);
  }

  public JsonObject addSection(TestRailClient testRailClient, long projectId, JsonObject section) throws TestRailException {
    return testRailClient.post(API_METHOD_ADD_SECTION + projectId, section);
  }

  public JsonObject deleteSection(TestRailClient testRailClient, long projectId) throws TestRailException {
    return testRailClient.post(API_METHOD_GET_SECTIONS + projectId, new JsonObject());
  }
}
