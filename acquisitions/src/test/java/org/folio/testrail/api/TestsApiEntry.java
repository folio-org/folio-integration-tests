package org.folio.testrail.api;

import java.io.IOException;
import org.json.simple.JSONArray;

public interface TestsApiEntry extends ApiEntry {

  JSONArray getTests(APIClient client, long runId) throws IOException, APIException;

}
