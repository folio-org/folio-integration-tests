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

@Order(8)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesCriticalPathApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice",
    "encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice",
    "encumbrance-remains-0-for-re-opened-0-dollar-ongoing-order-with-paid-invoice",
    "encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-and-credited-invoices",
    "encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-and-canceling-credited-invoice",
    "encumbrance-remains-0-for-reopened-one-time-order-with-approved-invoice-unreleasing-and-canceling-invoice",
    "encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-credit-and-paid-invoices-release-true",
    "encumbrance-calculated-correctly-after-canceling-approved-invoice-exceeding-initial-encumbrance-release-false",
    "encumbrance-remains-same-after-cancelling-credited-approved-invoice-release-false",
    "cancel-paid-invoice-after-changing-fund-distribution",
    "encumbrance-remains-unreleased-after-expense-class-change-with-paid-invoice-release-true",
    "encumbrance-and-budget-updated-correctly-after-editing-fund-distribution-and-increasing-cost-with-paid-invoice",
    "encumbrance-released-after-expense-class-change-in-pol-and-invoice-with-paid-invoice",
    "total-expended-no-encumbrances",
    "total-expended-different-fiscal-years",
    "total-expended-no-paid-invoices",
    "total-expended-different-fund-distributions",
    "encumbrance-after-canceling-paid-invoice-with-other-paid-invoices-release-false",
    "encumbrance-after-canceling-approved-invoice-with-other-approved-invoices-release-false",
    "encumbrance-after-canceling-paid-invoice-with-mixed-release-settings",
    "encumbrance-after-canceling-approved-invoice-with-mixed-release-settings",
    "rollover-two-ledgers-with-multi-fund-pol",
    "rollover-three-ledgers-with-expense-classes-twice",
    "rollover-three-ledgers-with-different-fund-distributions",
    "encumbrance-unreleased-after-unopening-order-with-paid-invoice-release-false",
    "encumbrance-released-after-unopening-order-with-paid-and-approved-invoices"
  };

  public CrossModulesCriticalPathApiTest() {
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
      destroyTenant();
    } finally {
      super.afterAll();
    }
  }

  @Test
  @DisplayName("(Thunderjet) Destroy tenant")
  @EnabledIfSystemProperty(named = "destroy", matches = "true")
  public void destroyTenantManually() {
    destroyTenant();
  }

  @Override
  public void destroyTenant() {
    SharedCrossModulesTenant.cleanupTenant(this.getClass(), this::runFeature);
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
