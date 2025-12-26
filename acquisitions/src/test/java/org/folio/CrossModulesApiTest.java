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

@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("approve-invoice-using-different-fiscal-years"),
    FEATURE_2("approve-invoice-with-negative-line"),
    FEATURE_3("audit-event-invoice"),
    FEATURE_4("audit-event-invoice-line"),
    FEATURE_5("audit-event-organization"),
    FEATURE_6("cancel-invoice-and-unrelease-2-encumbrances"),
    FEATURE_7("cancel-invoice-linked-to-order"),
    FEATURE_8("cancel-invoice-with-encumbrance"),
    FEATURE_9("change-fd-check-initial-amount"),
    FEATURE_10("change-poline-fd-and-pay-invoice"),
    FEATURE_11("check-approve-and-pay-invoice-with-invoice-references-same-po-line"),
    FEATURE_12("check-encumbrance-status-after-moving-expended-value"),
    FEATURE_13("check-encumbrances-after-issuing-credit-for-paid-order"),
    FEATURE_14("check-encumbrances-after-order-is-reopened"),
    FEATURE_15("check-encumbrances-after-order-is-reopened-2"),
    FEATURE_16("check-encumbrances-after-order-line-exchange-rate-update"),
    FEATURE_17("check-order-re-encumber-after-preview-rollover"),
    FEATURE_18("check-order-re-encumber-work-correctly"),
    FEATURE_19("check-order-total-fields-calculated-correctly"),
    FEATURE_20("check-payment-status-after-cancelling-paid-invoice"),
    FEATURE_21("check-paymentstatus-after-reopen"),
    FEATURE_22("check-po-numbers-updates"),
    FEATURE_23("check-po-numbers-updates-when-invoice-line-deleted"),
    FEATURE_24("create-order-and-approve-invoice-were-pol-without-fund-distributions"),
    FEATURE_25("create-order-and-invoice-with-odd-penny"),
    FEATURE_26("create-order-with-invoice-that-has-enough-money"),
    FEATURE_27("delete-encumbrance"),
    FEATURE_28("invoice-encumbrance-update-without-acquisition-unit"),
    FEATURE_29("ledger-fiscal-year-rollover"),
    FEATURE_30("ledger-fiscal-year-rollover-cash-balance"),
    FEATURE_31("link-invoice-line-to-po-line"),
    FEATURE_32("MODFISTO-270-delete-planned-budget-without-transactions"),
    FEATURE_33("moving_encumbered_value_to_different_budget"),
    FEATURE_34("moving_expended_value_to_newly_created_encumbrance"),
    FEATURE_35("open-approve-and-pay-order-with-50-lines"),
    FEATURE_36("open-order-after-approving-invoice"),
    FEATURE_37("order-invoice-relation"),
    FEATURE_38("order-invoice-relation-can-be-changed"),
    FEATURE_39("order-invoice-relation-can-be-deleted"),
    FEATURE_40("order-invoice-relation-must-be-deleted-if-invoice-deleted"),
    FEATURE_41("partial-rollover"),
    FEATURE_42("pay-invoice-and-delete-piece"),
    FEATURE_43("pay-invoice-with-new-expense-class"),
    FEATURE_44("pay-invoice-without-order-acq-unit-permission"),
    FEATURE_45("pending-payment-update-after-encumbrance-deletion"),
    FEATURE_46("remove-fund-distribution-after-rollover-when-re-encumber-false"),
    FEATURE_47("remove_linked_invoice_lines_fund_distribution_encumbrance_reference"),
    FEATURE_48("rollover-and-pay-invoice-using-past-fiscal-year"),
    FEATURE_49("rollover-with-closed-order"),
    FEATURE_50("rollover-with-no-settings"),
    FEATURE_51("rollover-with-pending-order"),
    FEATURE_52("unopen-approve-invoice-reopen"),
    FEATURE_53("unopen-order-and-add-addition-pol-and-check-encumbrances"),
    FEATURE_54("unopen-order-simple-case"),
    FEATURE_55("update-encumbrance-links-with-fiscal-year"),
    FEATURE_56("update_fund_in_poline_when_invoice_approved");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public CrossModulesApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
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
  @DisplayName("(Thunderjet) Run features")
  @EnabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void approveInvoiceUsingDifferentFiscalYears() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void approveInvoiceWithNegativeLine() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void auditEventInvoice() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void auditEventInvoiceLine() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void auditEventOrganization() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelInvoiceAndUnrelease2Encumbrances() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelInvoiceLinkedToOrder() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelInvoiceWithEncumbrance() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void changeFdCheckInitialAmount() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void changePolineFdAndPayInvoice() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkApproveAndPayInvoiceWithInvoiceReferencesSamePoLine() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEncumbranceStatusAfterMovingExpendedValue() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEncumbrancesAfterIssuingCreditForPaidOrder() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEncumbrancesAfterOrderIsReopened() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEncumbrancesAfterOrderIsReopened2() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEncumbrancesAfterOrderLineExchangeRateUpdate() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkOrderReEncumberAfterPreviewRollover() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkOrderTotalFieldsCalculatedCorrectly() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkPaymentStatusAfterCancellingPaidInvoice() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkPaymentStatusAfterReopen() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkPoNumbersUpdates() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkPoNumbersUpdatesWhenIinvoiceLineDeleted() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderAndApproveInvoiceWerePolWithoutFundDistributions() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderAndInvoiceWithOddPenny() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void deleteEncumbrance() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void invoiceEncumbranceUpdateWithoutAcquisitionUnit() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerRollover() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloverCashBalance() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void linkInvoiceLineToPoLine() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void deletePlannedBudgetWithoutTransactions() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void movingEncumberedValueToDifferentBudget() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void movingExpendedValueToNewlyCreatedEncumbrance() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openApproveAndPayOrderWith50Lines() {
    runFeatureTest(Feature.FEATURE_35.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderAfterApprovingInvoice() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void orderInvoiceRelation() {
    runFeatureTest(Feature.FEATURE_37.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void orderInvoiceRelationCanBeChanged() {
    runFeatureTest(Feature.FEATURE_38.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void orderInvoiceRelationCanBeDeleted() {
    runFeatureTest(Feature.FEATURE_39.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void order_invoice_relation_must_be_deleted_if_invoice_deleted() {
    runFeatureTest(Feature.FEATURE_40.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void partialRollover() {
    runFeatureTest(Feature.FEATURE_41.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void payInvoiceAndDeletePiece() {
    runFeatureTest(Feature.FEATURE_42.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void payInvoiceWithNewExpenseClass() {
    runFeatureTest(Feature.FEATURE_43.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void payInvoiceWithoutOrderAcqUnitPermission() {
    runFeatureTest(Feature.FEATURE_44.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pendingPaymentUpdateAfterEncumbranceDeletion() {
    runFeatureTest(Feature.FEATURE_45.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void removeFundDistributionAfterRolloverWhenReEncumberFalse() {
    runFeatureTest(Feature.FEATURE_46.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void removeLinkedInvoiceLinesFundDistributionEncumbranceReference() {
    runFeatureTest(Feature.FEATURE_47.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void rolloverAndPayInvoiceUsingPastFiscalYear() {
    runFeatureTest(Feature.FEATURE_48.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void rolloverWithClosedOrder() {
    runFeatureTest(Feature.FEATURE_49.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void rolloverWithNoSettings() {
    runFeatureTest(Feature.FEATURE_50.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void rolloverWithPendingOrder() {
    runFeatureTest(Feature.FEATURE_51.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unopenApproveInvoiceReopen() {
    runFeatureTest(Feature.FEATURE_52.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unopen_order_and_add_addition_pol_and_check_encumbrances() {
    runFeatureTest(Feature.FEATURE_53.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unopen_order_simple_case() {
    runFeatureTest(Feature.FEATURE_54.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateEncumbranceLinksWithFiscalYear() {
    runFeatureTest(Feature.FEATURE_55.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateFundInPoLineWhenInvoiceApproved() {
    runFeatureTest(Feature.FEATURE_56.getFileName());
  }
}
