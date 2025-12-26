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

@FolioTest(team = "thunderjet", module = "ebsconet")
public class EbsconetApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-ebsconet/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("cancel-order-lines-with-ebsconet"),
    FEATURE_2("close-order-with-order-line"),
    FEATURE_3("get-ebsconet-order-line"),
    FEATURE_4("update-ebsconet-order-line"),
    FEATURE_5("update-ebsconet-order-line-empty-locations"),
    FEATURE_6("update-mixed-order-line");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public EbsconetApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void ebsconetApiTestBeforeAll() {
    System.setProperty("testTenant", "testebsconet" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-ebsconet/init-ebsconet.feature");
  }

  @AfterAll
  public void ebsconetApiTestAfterAll() {
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
  void cancelOrderLinesWithEbsconet() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void closeOrderWithOrderLine() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void getEbsconetOrderLine() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateEbsconetOrderLine() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateEbsconetOrderLineEmptyLocations() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateEbsconetOrderLineMixedFormat() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }
}
