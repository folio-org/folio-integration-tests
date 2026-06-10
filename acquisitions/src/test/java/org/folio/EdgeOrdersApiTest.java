package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestFactory;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import java.util.Arrays;
import java.util.UUID;
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

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
@Order(13)
@FolioTest(team = "thunderjet", module = "edge-orders")
class EdgeOrdersApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/edge-orders/features/";
  private static final String TEST_TENANT = "testedgeorders";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "common",
    "ebsconet",
    "gobi",
    "mosaic"
  };

  public EdgeOrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", TEST_TENANT);
    System.setProperty("testEdgeUser", "test-user");
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/edge-orders/init-edge-orders.feature");
  }

  @AfterAll
  @Override
  public void afterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @Override
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  public void runFeatures() {
    runFeatures(Arrays.asList(FEATURES), THREAD_COUNT, null);
  }

  @TestFactory
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  @Execution(ExecutionMode.CONCURRENT)
  Stream<DynamicTest> runFeaturesSeparately() {
    return Stream.of(FEATURES).map(featureName -> dynamicTest(featureName, () -> runFeatureTest(featureName)));
  }
}
