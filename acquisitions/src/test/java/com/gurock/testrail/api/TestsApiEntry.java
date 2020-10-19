package com.gurock.testrail.api;

import com.gurock.testrail.APIClient;
import com.gurock.testrail.APIException;
import java.io.IOException;
import org.json.simple.JSONArray;

public interface TestsApiEntry extends ApiEntry {

  JSONArray getTests(APIClient client, long runId) throws IOException, APIException;

}
