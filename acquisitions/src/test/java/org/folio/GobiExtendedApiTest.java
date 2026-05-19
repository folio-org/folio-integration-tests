package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.shared.AcquisitionsTest;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@Order(17)
@FolioTest(team = "thunderjet", module = "mod-gobi")
class GobiExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";
  private static final String TEST_TENANT = "testgobiext";
  private static final int THREAD_COUNT = 1; // Gobi tests share tenant resources, must run sequentially

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("receipt-not-required-pending-order-independent-workflow", true),
    FEATURE_2("receipt-not-required-open-order-independent-workflow", true),
    FEATURE_3("order-without-location-fails-when-holdings-required", true),
    FEATURE_4("order-without-configured-locations", true),
    FEATURE_5("tenant-id-not-populated-on-non-ecs", true);

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

  public GobiExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-gobi/init-gobi.feature");
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
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C794526) Receipt Not Required Sets Receiving Workflow To Independent For Pending Order")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void receiptNotRequiredPendingOrderIndependentWorkflow() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C794527) Receipt Not Required Sets Receiving Workflow To Independent For Open Order")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void receiptNotRequiredOpenOrderIndependentWorkflow() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C852052) Order Without Location Fails When Inventory Interaction Requires Holdings")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderWithoutLocationFailsWhenHoldingsRequired() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C852048) Order Can Be Created Without Configured Locations In The System")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderWithoutConfiguredLocations() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) TenantId Is Not Populated By mod-gobi On Non-ECS Environment")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void tenantIdNotPopulatedOnNonEcs() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }
}