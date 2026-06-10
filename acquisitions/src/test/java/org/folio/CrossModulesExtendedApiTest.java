package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedCrossModulesTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.TestFactory;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import java.util.Arrays;
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

@Order(9)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "total-expended-with-fund-distribution-and-encumbrance",
    "budget-summary-when-amounts-exceed-available",
    "budget-summary-encumbered-approved-paid-exceed-available",
    "budget-summary-transfer-decreases-below-available",
    // moved from CrossModulesCriticalPathApiTest (TestRail group = Extended)
    "budget-and-encumbrance-updated-correctly-after-editing-pol-with-invoice-after-rollover",
    "unrelease-encumbrances-when-reopen-ongoing-order-with-related-paid-invoice-and-receiving",
    "rollover-based-on-expended-with-credit-invoice",
    "encumbrance-remains-same-after-cancelling-credited-invoice",
    "encumbrance-remains-same-after-cancelling-credit-invoice-with-another-paid-invoice",
    "encumbrance-updates-correctly-after-canceling-first-of-two-paid-invoices",
    "encumbrance-unreleased-after-cancelling-invoice-and-reopening-order",
    "encumbrance-calculated-correctly-after-canceling-invoice-with-other-paid-and-credit-invoices",
    "encumbrance-calculated-correctly-after-canceling-approved-invoice-with-other-invoices-release-false",
    "encumbrance-unreleased-after-cancelling-approved-invoice-and-re-opening-order-release-false",
    "encumbrance-after-removing-fund-distribution-from-pol",
    "encumbrance-released-after-manual-release-and-fund-change-ongoing",
    "encumbrance-released-after-fund-change-with-paid-invoice-release-true",
    "encumbrance-released-after-manual-release-and-fund-change-with-paid-invoice-release-false",
    "subscription-and-tags-editable-in-paid-invoice-after-rollover-with-closed-budget",
    "subscription-and-tags-editable-in-approved-invoice-with-inactive-budget",
    "fund-distribution-can-be-changed-after-rollover-when-re-encumber-not-active",
    // moved from CrossModulesCriticalPathApiTest (TestRail group = Extended)
    "encumbrance-remains-unreleased-after-expense-class-change-with-paid-invoice-release-false",
    "over-encumbrance-for-fy-ledger-and-group",
    "check-encumbrance-restrictions-when-opening-order",
    "expense-class-percent-expended-when-budget-over-expended",
    "rollover-settings-no-encumbrances",
    "unreleased-encumbrance-rolled-over-to-next-fiscal-year",
    "invoice-encumbrance-update-without-acquisition-unit",
    "encumbrance-remains-released-after-another-credited-invoice-was-paid",
    "encumbrance-calculated-correctly-after-cancelling-paid-credit-invoice"
  };

  public CrossModulesExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedCrossModulesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    try {
      SharedCrossModulesTenant.cleanupTenant(this.getClass(), this::runFeature);
    } finally {
      super.afterAll();
    }
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
