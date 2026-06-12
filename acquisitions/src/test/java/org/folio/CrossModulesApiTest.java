package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedCrossModulesTenant;
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
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

@Order(7)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "approve-invoice-using-different-fiscal-years",
    "approve-invoice-with-negative-line",
    "audit-event-invoice",
    "audit-event-invoice-line",
    "audit-event-organization",
    "auto-reopen-order-in-new-fy",
    "cancel-invoice-and-unrelease-2-encumbrances",
    "cancel-invoice-linked-to-order",
    "cancel-invoice-with-encumbrance",
    "change-fd-check-initial-amount",
    "change-poline-fd-and-pay-invoice",
    "check-approve-and-pay-invoice-with-invoice-references-same-po-line",
    "check-encumbrance-status-after-moving-expended-value",
    "check-encumbrances-after-order-is-reopened",
    "check-encumbrances-after-order-is-reopened-2",
    "check-encumbrances-after-order-line-exchange-rate-update",
    "check-order-re-encumber-after-preview-rollover",
    "check-order-re-encumber-work-correctly",
    "check-order-total-fields-calculated-correctly",
    "check-payment-status-after-cancelling-paid-invoice",
    "check-paymentstatus-after-reopen",
    "check-po-numbers-updates",
    "check-po-numbers-updates-when-invoice-line-deleted",
    "create-order-and-approve-invoice-were-pol-without-fund-distributions",
    "create-order-and-invoice-with-odd-penny",
    "create-order-with-invoice-that-has-enough-money",
    "delete-encumbrance",
    "ledger-fiscal-year-rollover",
    "ledger-fiscal-year-rollover-cash-balance",
    "link-invoice-line-to-po-line",
    "MODFISTO-270-delete-planned-budget-without-transactions",
    "moving_encumbered_value_to_different_budget",
    "moving_expended_value_to_newly_created_encumbrance",
    "open-approve-and-pay-order-with-50-lines",
    "open-order-after-approving-invoice",
    "order-invoice-relation",
    "order-invoice-relation-can-be-changed",
    "order-invoice-relation-can-be-deleted",
    "order-invoice-relation-must-be-deleted-if-invoice-deleted",
    "partial-rollover",
    "pay-invoice-and-delete-piece",
    "pay-invoice-with-new-expense-class",
    "pay-invoice-without-order-acq-unit-permission",
    "pending-payment-update-after-encumbrance-deletion",
    "remove-fund-distribution-after-rollover-when-re-encumber-false",
    "remove_linked_invoice_lines_fund_distribution_encumbrance_reference",
    "rollover-and-pay-invoice-using-past-fiscal-year",
    "rollover-with-closed-order",
    "rollover-with-no-settings",
    "rollover-with-pending-order",
    "unopen-approve-invoice-reopen",
    "unopen-order-and-add-addition-pol-and-check-encumbrances",
    "unopen-order-simple-case",
    "update-encumbrance-links-with-fiscal-year",
    "update_fund_in_poline_when_invoice_approved",
    "rollover-multi-ledger",
    // disabled because it is very long
    /*"rollover-many-orders-and-lines",*/
    "approve-invoice-with-different-fund-than-order",
    "rollover-one-order-type",
    "pay-unopen-open"
  };

  public CrossModulesApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedCrossModulesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
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
