package org.folio.testrail.api;

import java.io.IOException;
import org.json.simple.JSONObject;

public interface RunsApiEntry extends ApiEntry {

  JSONObject addRun(APIClient client, long projectId, JSONObject data)
      throws IOException, APIException;

}
