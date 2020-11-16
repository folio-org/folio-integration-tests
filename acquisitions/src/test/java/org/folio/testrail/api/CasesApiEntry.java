package org.folio.testrail.api;

import java.io.IOException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public interface CasesApiEntry extends ApiEntry {

  JSONArray getCases(
      APIClient client, long projectId, long suiteId) throws IOException, APIException;

  JSONObject addCase(APIClient client, long sectionId, JSONObject data) throws IOException, APIException;

  void deleteCase(APIClient client, long caseId) throws IOException, APIException;

}
