package org.folio;

import org.apache.commons.lang3.RandomUtils;
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

@FolioTest(team = "thunderjet", module = "mod-mosaic")
class MosaicApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-mosaic/features/";
  private static final String TEST_TENANT = "testmosaic";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("create-order-1-from-minimal-template.feature", true),
    FEATURE_2("create-order-2-from-default-template.feature", true),
    FEATURE_3("create-order-3-from-physical-template.feature", true),
    FEATURE_4("create-order-4-from-electronic-template.feature", true),
    FEATURE_5("create-order-5-from-pe-mix-template.feature", true),
    FEATURE_6("create-order-6-with-open-workflow-status.feature", true),
    FEATURE_7("create-order-7-with-check-in-items.feature", true),
    FEATURE_8("validate-order.feature", true);

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

  MosaicApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void mosaicApiTestBeforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-mosaic/init-mosaic.feature");
  }

  @AfterAll
  void mosaicApiTestAfterAll() {
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
  void createOrder1FromMinimalTemplate() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder2FromDefaultTemplate() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder3FromPhysicalTemplate() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder4FromElectronicTemplate() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder5FromPEMixTemplate() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder6WithOpenWorkflowStatus() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrder7WithCheckInItems() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void validateOrder() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }
}
