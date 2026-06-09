package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.shared.AcquisitionsTest;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.CommonFeature;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@Order(18)
@FolioTest(team = "thunderjet", module = "mod-data-export-spring")
class DataExportSpringExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-data-export-spring/features/";
  private static final String TEST_TENANT = "testexportext";
  private static final int THREAD_COUNT = 1; // Scheduled EDI export tests must run sequentially (shared quartz scheduler / minute-boundary timing)

  private enum Feature implements CommonFeature {
    FEATURE_1("exported-order-not-repeated-in-next-exports", true),
    FEATURE_2("automatic-export-flag-triggers-edifact-export", true);

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

  public DataExportSpringExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-data-export-spring/init-data-export-spring.feature");
  }

  @AfterAll
  @Override
  public void afterAll() {
    try {
      runFeature("classpath:common/eureka/destroy-data.feature");
    } finally {
      super.afterAll();
    }
  }

  @Test
  @Override
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  public void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C358971) Already exported order is not included repeatedly in next exports")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void alreadyExportedOrderNotRepeated() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C350543) Saved automaticExport flag in PO line supports EDIFACT orders export")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void automaticExportFlagTriggersEdifactExport() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }
}

