package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";

  public CrossModulesApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void crossModuleApiTestBeforeAll() {
    System.setProperty("testTenant", "testcross" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/cross-modules/init-cross-modules.feature");
  }

  @AfterAll
  public void crossModuleApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }


  @Test
  void approveInvoiceUsingDifferentFiscalYears() {
    runFeatureTest("approve-invoice-using-different-fiscal-years");
  }

  @Test
  void approveInvoiceWithNegativeLine() {
    runFeatureTest("approve-invoice-with-negative-line");
  }

  @Test
  void auditEventInvoice() {
    runFeatureTest("audit-event-invoice");
  }

  @Test
  void auditEventInvoiceLine() {
    runFeatureTest("audit-event-invoice-line");
  }

  @Test
  void auditEventOrganization() {
    runFeatureTest("audit-event-organization");
  }

  @Test
  void cancelInvoiceAndUnrelease2Encumbrances() {
    runFeatureTest("cancel-invoice-and-unrelease-2-encumbrances");
  }

  @Test
  void cancelInvoiceLinkedToOrder() {
    runFeatureTest("cancel-invoice-linked-to-order");
  }

  @Test
  void cancelInvoiceWithEncumbrance() {
    runFeatureTest("cancel-invoice-with-encumbrance");
  }

  @Test
  void changeFdCheckInitialAmount() {
    runFeatureTest("change-fd-check-initial-amount");
  }

  @Test
  void changePolineFdAndPayInvoice() {
    runFeatureTest("change-poline-fd-and-pay-invoice");
  }

  @Test
  void checkApproveAndPayInvoiceWithInvoiceReferencesSamePoLine() {
    runFeatureTest("check-approve-and-pay-invoice-with-invoice-references-same-po-line");
  }

  @Test
  void checkEncumbranceStatusAfterMovingExpendedValue() {
    runFeatureTest("check-encumbrance-status-after-moving-expended-value");
  }

  @Test
  void checkEncumbrancesAfterIssuingCreditForPaidOrder() {
    runFeatureTest("check-encumbrances-after-issuing-credit-for-paid-order");
  }

  @Test
  void checkEncumbrancesAfterOrderIsReopened() {
    runFeatureTest("check-encumbrances-after-order-is-reopened");
  }

  @Test
  void checkEncumbrancesAfterOrderIsReopened2() {
    runFeatureTest("check-encumbrances-after-order-is-reopened-2");
  }

  @Test
  void checkEncumbrancesAfterOrderLineExchangeRateUpdate() {
    runFeatureTest("check-encumbrances-after-order-line-exchange-rate-update");
  }

  @Test
  void checkOrderReEncumberAfterPreviewRollover() {
    runFeatureTest("check-order-re-encumber-after-preview-rollover");
  }

  @Test
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest("check-order-re-encumber-work-correctly");
  }

  @Test
  void checkOrderTotalFieldsCalculatedCorrectly() {
    runFeatureTest("check-order-total-fields-calculated-correctly");
  }

  @Test
  void checkPaymentStatusAfterCancellingPaidInvoice() {
    runFeatureTest("check-payment-status-after-cancelling-paid-invoice");
  }

  @Test
  void checkPaymentStatusAfterReopen() {
    runFeatureTest("check-paymentstatus-after-reopen");
  }

  @Test
  void checkPoNumbersUpdates() {
    runFeatureTest("check-po-numbers-updates");
  }

  @Test
  void checkPoNumbersUpdatesWhenIinvoiceLineDeleted() {
    runFeatureTest("check-po-numbers-updates-when-invoice-line-deleted");
  }

  @Test
  void createOrderAndApproveInvoiceWerePolWithoutFundDistributions() {
    runFeatureTest("create-order-and-approve-invoice-were-pol-without-fund-distributions");
  }

  @Test
  void createOrderAndInvoiceWithOddPenny() {
    runFeatureTest("create-order-and-invoice-with-odd-penny");
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest("create-order-with-invoice-that-has-enough-money");
  }

  @Test
  void deleteEncumbrance() {
    runFeatureTest("delete-encumbrance");
  }

  @Test
  void invoiceEncumbranceUpdateWithoutAcquisitionUnit() {
    runFeatureTest("invoice-encumbrance-update-without-acquisition-unit");
  }

  @Test
  void ledgerRollover() {
    runFeatureTest("ledger-fiscal-year-rollover");
  }

  @Test
  void ledgerFiscalYearRolloverCashBalance() {
    runFeatureTest("ledger-fiscal-year-rollover-cash-balance");
  }

  @Test
  void linkInvoiceLineToPoLine() {
    runFeatureTest("link-invoice-line-to-po-line");
  }

  @Test
  void deletePlannedBudgetWithoutTransactions() {
    runFeatureTest("MODFISTO-270-delete-planned-budget-without-transactions");
  }

  @Test
  void movingEncumberedValueToDifferentBudget() {
    runFeatureTest("moving_encumbered_value_to_different_budget");
  }

  @Test
  void movingExpendedValueToNewlyCreatedEncumbrance() {
    runFeatureTest("moving_expended_value_to_newly_created_encumbrance");
  }

  @Test
  void openApproveAndPayOrderWith50Lines() {runFeatureTest("open-approve-and-pay-order-with-50-lines");}

  @Test
  void openOrderAfterApprovingInvoice() {
    runFeatureTest("open-order-after-approving-invoice");
  }

  @Test
  void orderInvoiceRelation() {
    runFeatureTest("order-invoice-relation");
  }

  @Test
  void orderInvoiceRelationCanBeChanged() {
    runFeatureTest("order-invoice-relation-can-be-changed");
  }

  @Test
  void orderInvoiceRelationCanBeDeleted() {
    runFeatureTest("order-invoice-relation-can-be-deleted");
  }

  @Test
  void order_invoice_relation_must_be_deleted_if_invoice_deleted() {
    runFeatureTest("order-invoice-relation-must-be-deleted-if-invoice-deleted");
  }

  @Test
  void partialRollover() {
    runFeatureTest("partial-rollover");
  }

  @Test
  void payInvoiceAndDeletePiece() {
    runFeatureTest("pay-invoice-and-delete-piece");
  }

  @Test
  void payInvoiceWithNewExpenseClass() {
    runFeatureTest("pay-invoice-with-new-expense-class");
  }

  @Test
  void payInvoiceWithoutOrderAcqUnitPermission() {
    runFeatureTest("pay-invoice-without-order-acq-unit-permission");
  }

  @Test
  void pendingPaymentUpdateAfterEncumbranceDeletion() {
    runFeatureTest("pending-payment-update-after-encumbrance-deletion");
  }

  @Test
  void removeFundDistributionAfterRolloverWhenReEncumberFalse() {
    runFeatureTest("remove-fund-distribution-after-rollover-when-re-encumber-false");
  }

  @Test
  void removeLinkedInvoiceLinesFundDistributionEncumbranceReference() {
    runFeatureTest("remove_linked_invoice_lines_fund_distribution_encumbrance_reference");
  }

  @Test
  void rolloverAndPayInvoiceUsingPastFiscalYear() {
    runFeatureTest("rollover-and-pay-invoice-using-past-fiscal-year");
  }

  @Test
  void rolloverWithClosedOrder() {
    runFeatureTest("rollover-with-closed-order");
  }

  @Test
  void rolloverWithNoSettings() {
    runFeatureTest("rollover-with-no-settings");
  }

  @Test
  void rolloverWithPendingOrder() {
    runFeatureTest("rollover-with-pending-order");
  }

  @Test
  void unopenApproveInvoiceReopen() {
    runFeatureTest("unopen-approve-invoice-reopen");
  }

  @Test
  void unopen_order_and_add_addition_pol_and_check_encumbrances() {
    runFeatureTest("unopen-order-and-add-addition-pol-and-check-encumbrances");
  }

  @Test
  void unopen_order_simple_case() {
    runFeatureTest("unopen-order-simple-case");
  }

  @Test
  void updateEncumbranceLinksWithFiscalYear() {
    runFeatureTest("update-encumbrance-links-with-fiscal-year");
  }

  @Test
  void updateFundInPoLineWhenInvoiceApproved() {
    runFeatureTest("update_fund_in_poline_when_invoice_approved");
  }

  @Test
  void encumbranceCalculatedCorrectlyForUnopenedOngoingOrderWithApprovedInvoice() {
    runFeatureTest("encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice");
  }

  @Test
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoiceUnreleasingEncumbranceAndCancelingAnotherPaidInvoice() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-encumbrance-and-canceling-another-paid-invoice");
  }
}
