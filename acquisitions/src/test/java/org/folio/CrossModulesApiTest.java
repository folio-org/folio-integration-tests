package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";

  public CrossModulesApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void approveInvoiceWithNegativeLine() {
    runFeatureTest("approve-invoice-with-negative-line");
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
  void checkPoNumbersUpdates() {
    runFeatureTest("check-po-numbers-updates");
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest("create-order-with-invoice-that-has-enough-money");
  }

  @Test
  void createOrderAndInvoiceWithOddPenny() {
    runFeatureTest("create-order-and-invoice-with-odd-penny");
  }

  @Test
  void deleteEncumbrance() {
    runFeatureTest("delete-encumbrance");
  }

  @Test
  void linkInvoiceLineToPoLine() {
    runFeatureTest("link-invoice-line-to-po-line");
  }

  @Test
  void orderInvoiceRelation() {
    runFeatureTest("order-invoice-relation");
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
  void chekPoNumbersUpdatesWhenIinvoiceLineDeleted() {
    runFeatureTest("chek-po-numbers-updates-when-invoice-line-deleted");
  }

  @Test
  void createOrderAndApproveInvoiceWerePolWithoutFundDistributions() {
    runFeatureTest("create-order-and-approve-invoice-were-pol-without-fund-distributions");
  }

  @Test
  void deletePlannedBudgetWithoutTransactions() {
    runFeatureTest("MODFISTO-270-delete-planned-budget-without-transactions");
  }

  @Test
  void payInvoiceWithNewExpenseClass() {
    runFeatureTest("pay-invoice-with-new-expense-class");
  }

  @Test
  void changePolineFdAndPayInvoice() {
    runFeatureTest("change-poline-fd-and-pay-invoice");
  }

  @Test
  void cancelInvoiceLinkedToOrder() {
    runFeatureTest("cancel-invoice-linked-to-order");
  }

  @Test
  void checkApproveAndPayInvoiceWithInvoiceReferencesSamePoLine() {
    runFeatureTest("check-approve-and-pay-invoice-with-invoice-references-same-po-line");
  }

  @Test
  void cancelInvoiceAndUnrelease2Encumbrances() {
    runFeatureTest("cancel-invoice-and-unrelease-2-encumbrances");
  }

  @Test
  void approveInvoiceUsingDifferentFiscalYears() {
    runFeatureTest("approve-invoice-using-different-fiscal-years");
  }

  @Test
  void partialRollover() {
    runFeatureTest("partial-rollover");
  }

  @Test
  void rolloverWithClosedOrder() {
    runFeatureTest("rollover-with-closed-order");
  }

  @Test
  void payInvoiceAndDeletePiece() {
    runFeatureTest("pay-invoice-and-delete-piece");
  }

  @Test
  void unopenApproveInvoiceReopen() {
    runFeatureTest("unopen-approve-invoice-reopen");
  }

  @Test
  void changeFdCheckInitialAmount() {
    runFeatureTest("change-fd-check-initial-amount");
  }

  @BeforeAll
  public void crossModuleApiTestBeforeAll() {
    runFeature("classpath:thunderjet/cross-modules/cross-modules-junit.feature");
  }

  @AfterAll
  public void crossModuleApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}

