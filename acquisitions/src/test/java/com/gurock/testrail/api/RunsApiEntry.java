package com.gurock.testrail.api;

import com.gurock.testrail.APIClient;
import com.gurock.testrail.APIException;
import java.io.IOException;
import org.json.simple.JSONObject;

public interface RunsApiEntry extends ApiEntry {

  JSONObject addRun(APIClient client, long projectId, JSONObject data)
      throws IOException, APIException;

}
