package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

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
  private static final String TEST_TENANT = "testedgeorders";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("common", true),
    FEATURE_2("ebsconet", true),
    FEATURE_3("gobi", true),
    FEATURE_4("mosaic", true);

    private final String fileName;
    private final boolean isEnabled;

    Feature(String fileName, boolean isEnabled) {
      this.fileName = fileName;
      this.isEnabled = isEnabled;
    }

    public boolean isEnabled() {
      return isEnabled;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public EdgeOrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void edgeOrdersApiTestBeforeAll() {
    System.setProperty("testTenant", TEST_TENANT);
    System.setProperty("testEdgeUser", "test-user");
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/edge-orders/init-edge-orders.feature");
  }

  @AfterAll
  void edgeOrdersApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void common() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ebsconet() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void gobi() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void mosaic() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }
}
