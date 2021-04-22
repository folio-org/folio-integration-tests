package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
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
public class EdgeOrdersApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/edge-orders/features/";
  private static final String TEST_SUITE_NAME = "edge-orders";
  // TEST_SUITE_ID and TEST_SECTION_ID are obtained from TestRail
  private static final long TEST_SUITE_ID = 1058L;
  private static final long TEST_SECTION_ID = 15155L;

  public EdgeOrdersApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
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
    runFeature("classpath:domain/edge-orders/edge-orders-junit.feature");
  }

  @AfterAll
  public void edgeOrdersApiTestAfterAll() {
    runFeature("classpath:domain/edge-orders/edge-orders-destroy-data.feature");
  }

}
