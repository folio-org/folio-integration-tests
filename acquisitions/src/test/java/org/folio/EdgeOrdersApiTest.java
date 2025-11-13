package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

/**
 * For this test suite to work, edge-orders has to be started on port 19000 using an ephemeral.properties
 * file including test_edge_orders in the list of tenants and with the following lines:
 *   secureStore.type=Ephemeral
 *   tenants=testedgeorders
 *   testedgeorders=test-user,test
 * Example of a command to start edge-orders locally:
 *   java -Dport=19000 -Dokapi_url=http://localhost:8000 -Dsecure_store_props=path/to/ephemeral.properties -jar target/edge-orders-fat.jar
 * The port number to use for edge modules is specified in karate-config.js.
 */
@FolioTest(team = "thunderjet", module = "edge-orders")
class EdgeOrdersApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/edge-orders/features/";

  public EdgeOrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void edgeOrdersApiTestBeforeAll() {
    System.setProperty("testTenant", "testedgeorders");
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/edge-orders/init-edge-orders.feature");
  }

  @AfterAll
  void edgeOrdersApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void common() {
    runFeatureTest("common");
  }

  @Test
  void ebsconet() {
    runFeatureTest("ebsconet");
  }

  @Test
  void gobi() {
    runFeatureTest("gobi");
  }

  @Test
  void mosaic() {
    runFeatureTest("mosaic");
  }
}
