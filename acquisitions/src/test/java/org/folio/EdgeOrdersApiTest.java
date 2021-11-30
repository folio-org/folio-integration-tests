package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

/**
 * NOTE: For this test suite to work, edge-orders has to be started on port 8000 using an ephemeral.properties
 * file including test_edge_orders in the list of tenants and with the following line:
 * test_edge_orders=test-user,test
 * Example of a command to start edge-orders locally:
 * java -Dport=8000 -Dokapi_url=http://localhost:9130 -Dsecure_store_props=path/to/ephemeral.properties -jar target/edge-orders-fat.jar
 * The port number to use for edge modules is specified in karate-config.js.
 */
public class EdgeOrdersApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/edge-orders/features/";

  public EdgeOrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void ebsconet() {
    runFeatureTest("ebsconet");
  }

  @Test
  void gobi() {
    runFeatureTest("gobi");
  }

  @BeforeAll
  public void edgeOrdersApiTestBeforeAll() {
    runFeature("classpath:thunderjet/edge-orders/edge-orders-junit.feature");
  }

  @AfterAll
  public void edgeOrdersApiTestAfterAll() {
    runFeature("classpath:thunderjet/edge-orders/edge-orders-destroy-data.feature");
  }

}
