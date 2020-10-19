package com.gurock.testrail.api;

import com.gurock.testrail.APIClient;
import com.gurock.testrail.APIException;
import java.io.IOException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public interface ResultsApiEntry extends ApiEntry {

  JSONArray addResultsForCases(APIClient client, long runId, JSONObject resultsForCases)
      throws IOException, APIException;
}
