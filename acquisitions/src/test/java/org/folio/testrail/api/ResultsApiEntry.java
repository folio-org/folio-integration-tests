package org.folio.testrail.api;

import java.io.IOException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public interface ResultsApiEntry extends ApiEntry {

  JSONArray addResultsForCases(APIClient client, long runId, JSONObject resultsForCases)
      throws IOException, APIException;
}
