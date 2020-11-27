package org.folio.testrail.api;

import static org.springframework.http.MediaType.APPLICATION_JSON;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import io.vertx.core.json.JsonObject;

public class TestRailClient {

  private final  String username;
  private final String password;
  private final String baseUrl;
  private final RestTemplate restTemplate;

  public TestRailClient() {
    String systemBaseUrl = System.getProperty("testrail_url");
    if (!systemBaseUrl.endsWith("/")) {
      systemBaseUrl += "/";
    }
    this.baseUrl = systemBaseUrl + "index.php?/api/v2/";
    this.username = System.getProperty("testrail_userId");
    this.password = System.getProperty("testrail_pwd");
    this.restTemplate = new RestTemplate();
  }


  private HttpHeaders getDefaultHeaders() {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(APPLICATION_JSON);
    headers.setBasicAuth(username, password);
    return headers;
  }


  public List<JsonObject> getCollection(String uri) throws TestRailException {
    Object responseBody = sendRequest(uri, HttpMethod.GET, null);
    return responseAsList(responseBody);
  }

  
  public JsonObject get(String uri) throws TestRailException {
    Object responseBody = sendRequest(uri, HttpMethod.GET, new JsonObject());
    return JsonObject.mapFrom(responseBody);
  }

  
  public JsonObject post(String uri, JsonObject entity) throws TestRailException {
    Object responseBody = sendRequest(uri, HttpMethod.POST, entity);
    return JsonObject.mapFrom(responseBody);
  }

  
  public List<JsonObject> postCollectionResponse(String uri, JsonObject entity) throws TestRailException {
    Object responseBody = sendRequest(uri, HttpMethod.POST, entity);
    return responseAsList(responseBody);
  }

  public Object sendRequest(String uri, HttpMethod httpMethod, JsonObject entity) throws TestRailException {
    HttpHeaders headers = getDefaultHeaders();
    HttpEntity<String> requestEntity;
    if (HttpMethod.POST.equals(httpMethod)) {
      headers.setAccept(Collections.singletonList(APPLICATION_JSON));
      requestEntity = new HttpEntity<>(entity.encode(), headers);
    } else {
      requestEntity = new HttpEntity<>(headers);
    }
    ResponseEntity<Object> response = restTemplate.exchange(baseUrl + uri, httpMethod, requestEntity, Object.class);
    if (response.getStatusCodeValue() >= 200 && response.getStatusCodeValue() < 300) {
      return response.getBody();
    }
    throw new TestRailException(response.getStatusCode().toString());
  }

  
  private List<JsonObject> responseAsList(Object responseBody) {
    return ((List<Object>) responseBody).stream()
      .map(JsonObject::mapFrom)
      .collect(Collectors.toList());
  }

}
