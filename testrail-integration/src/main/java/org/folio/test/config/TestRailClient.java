package org.folio.test.config;

import static org.folio.test.config.TestRailEnv.TESTRAIL_PWD;
import static org.folio.test.config.TestRailEnv.TESTRAIL_HOST;
import static org.folio.test.config.TestRailEnv.TESTRAIL_USER_ID;
import static org.springframework.http.MediaType.APPLICATION_JSON;

import java.util.Collections;
import java.util.Optional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.folio.test.utils.EnvUtils;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.web.client.RestTemplate;

public class TestRailClient {

  private final String baseUrl;
  private final String username;
  private final String password;
  private final ObjectMapper objectMapper;
  private final RestTemplate restTemplate;

  public TestRailClient() {
    this.baseUrl = Optional.ofNullable(System.getenv().get(TESTRAIL_HOST.name()))
      .map(TestRailClient::getBaseUrl)
      .orElse(null);
    this.username = EnvUtils.getString(TESTRAIL_USER_ID);
    this.password = EnvUtils.getString(TESTRAIL_PWD);
    this.objectMapper =  new ObjectMapper();
    this.restTemplate = new RestTemplate();
  }

  private static String getBaseUrl(String url) {
    var systemBaseUrl = url;
    if (!systemBaseUrl.endsWith("/")) {
      systemBaseUrl += "/";
    }

    return systemBaseUrl + "index.php?/api/v2/";
  }

  public <T> T get(String uri, ParameterizedTypeReference<T> typeReference) {
    return sendRequest(uri, HttpMethod.GET, null, typeReference);
  }

  public <T> T post(String uri, Object payload, ParameterizedTypeReference<T> typeReference) {
    var entity = (String) null;
    try {
      entity = objectMapper.writeValueAsString(payload);
    } catch (JsonProcessingException e) {
      throw new TestRailException("Failed to serialize payload into entity", e);
    }
    return sendRequest(uri, HttpMethod.POST, entity, typeReference);
  }

  public <T> T sendRequest(String uri, HttpMethod httpMethod, String entity, ParameterizedTypeReference<T> typeReference) {
    var requestEntity = getRequestEntity(httpMethod, entity);
    var response = restTemplate.exchange(baseUrl + uri, httpMethod, requestEntity, typeReference);
    if (!response.getStatusCode().is2xxSuccessful()) {
      throw new TestRailException(response.getStatusCode().toString());
    }
    return response.getBody();
  }

  private HttpEntity<String> getRequestEntity(HttpMethod httpMethod, String entity) {
    var headers = getHeaders();
    if (HttpMethod.POST.equals(httpMethod)) {
      headers.setAccept(Collections.singletonList(APPLICATION_JSON));
      return new HttpEntity<>(entity, headers);
    }
    return new HttpEntity<>(headers);
  }

  private HttpHeaders getHeaders() {
    var headers = new HttpHeaders();
    headers.setContentType(APPLICATION_JSON);
    headers.setBasicAuth(username, password);
    return headers;
  }
}
