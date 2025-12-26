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

@FolioTest(team = "thunderjet", module = "mod-gobi")
class GobiApiTest extends TestBaseEureka {

  // Default module settings :
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("gobi-api-tests"),
    FEATURE_2("find-holdings-by-location-and-instance"),
    FEATURE_3("validate-pol-receipt-not-required-with-checkin-items"),
    FEATURE_4("validate-pol-suppress-instance-from-discovery");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public GobiApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void gobiApiTestBeforeAll() {
    System.setProperty("testTenant", "testmodgobi" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-gobi/init-gobi.feature");
  }

  @AfterAll
  void gobiApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @EnabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void gobiApiTests() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void findHoldingsByLocationAndInstance() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void validatePoLineReceiptNotRequiredWithCheckinItems() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void validatePoLineSuppressInstanceFromDiscovery() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }
}
