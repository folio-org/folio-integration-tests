package org.folio;

import org.folio.shared.SharedCrossModulesTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@Order(9)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesExtendedApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("total-expended-with-fund-distribution-and-encumbrance", true),
    FEATURE_2("budget-summary-when-amounts-exceed-available", true),
    FEATURE_3("budget-summary-encumbered-approved-paid-exceed-available", true),
    FEATURE_4("budget-summary-transfer-decreases-below-available", true);

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

  public CrossModulesExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void crossModuleExtendedApiTestBeforeAll() {
    SharedCrossModulesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  public void crossModulesExtendedApiTestAfterAll() {
    SharedCrossModulesTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C594417) Total Expended Amount Calculation With Fund Distribution And Encumbrance")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedWithFundDistributionAndEncumbrance() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496145) Correct Financial Summary Values When Approved And Paid Amounts Exceed Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenAmountsExceedAvailable() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496149) Correct Financial Summary Values When Encumbered Approved And Paid Amounts Exceed Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenEncumberedApprovedAndPaidExceedAvailable() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496153) Correct Financial Summary Values When Decrease Allocation Exceeds Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenDecreaseAllocationExceedsAvailable() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }
}
