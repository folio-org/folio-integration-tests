package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@Order(6)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("approve-invoice-using-different-fiscal-years", true),
    FEATURE_2("approve-invoice-with-negative-line", true),
    FEATURE_3("audit-event-invoice", true),
    FEATURE_4("audit-event-invoice-line", true),
    FEATURE_5("audit-event-organization", true),
    FEATURE_6("cancel-invoice-and-unrelease-2-encumbrances", true),
    FEATURE_7("cancel-invoice-linked-to-order", true),
    FEATURE_8("cancel-invoice-with-encumbrance", true),
    FEATURE_9("change-fd-check-initial-amount", true),
    FEATURE_10("change-poline-fd-and-pay-invoice", true),
    FEATURE_11("check-approve-and-pay-invoice-with-invoice-references-same-po-line", true),
    FEATURE_12("check-encumbrance-status-after-moving-expended-value", true),
    FEATURE_13("check-encumbrances-after-issuing-credit-for-paid-order", true),
    FEATURE_14("check-encumbrances-after-order-is-reopened", true),
    FEATURE_15("check-encumbrances-after-order-is-reopened-2", true),
    FEATURE_16("check-encumbrances-after-order-line-exchange-rate-update", true),
    FEATURE_17("check-order-re-encumber-after-preview-rollover", true),
    FEATURE_18("check-order-re-encumber-work-correctly", true),
    FEATURE_19("check-order-total-fields-calculated-correctly", true),
    FEATURE_20("check-payment-status-after-cancelling-paid-invoice", true),
    FEATURE_21("check-paymentstatus-after-reopen", true),
    FEATURE_22("check-po-numbers-updates", true),
    FEATURE_23("check-po-numbers-updates-when-invoice-line-deleted", true),
    FEATURE_24("create-order-and-approve-invoice-were-pol-without-fund-distributions", true),
    FEATURE_25("create-order-and-invoice-with-odd-penny", true),
    FEATURE_26("create-order-with-invoice-that-has-enough-money", true),
    FEATURE_27("delete-encumbrance", true),
    FEATURE_28("invoice-encumbrance-update-without-acquisition-unit", true),
    FEATURE_29("ledger-fiscal-year-rollover", true),
    FEATURE_30("ledger-fiscal-year-rollover-cash-balance", true),
    FEATURE_31("link-invoice-line-to-po-line", true),
    FEATURE_32("MODFISTO-270-delete-planned-budget-without-transactions", true),
    FEATURE_33("moving_encumbered_value_to_different_budget", true),
    FEATURE_34("moving_expended_value_to_newly_created_encumbrance", true),
    FEATURE_35("open-approve-and-pay-order-with-50-lines", true),
    FEATURE_36("open-order-after-approving-invoice", true),
    FEATURE_37("order-invoice-relation", true),
    FEATURE_38("order-invoice-relation-can-be-changed", true),
    FEATURE_39("order-invoice-relation-can-be-deleted", true),
    FEATURE_40("order-invoice-relation-must-be-deleted-if-invoice-deleted", true),
    FEATURE_41("partial-rollover", true),
    FEATURE_42("pay-invoice-and-delete-piece", true),
    FEATURE_43("pay-invoice-with-new-expense-class", true),
    FEATURE_44("pay-invoice-without-order-acq-unit-permission", true),
    FEATURE_45("pending-payment-update-after-encumbrance-deletion", true),
    FEATURE_46("remove-fund-distribution-after-rollover-when-re-encumber-false", true),
    FEATURE_47("remove_linked_invoice_lines_fund_distribution_encumbrance_reference", true),
    FEATURE_48("rollover-and-pay-invoice-using-past-fiscal-year", true),
    FEATURE_49("rollover-with-closed-order", true),
    FEATURE_50("rollover-with-no-settings", true),
    FEATURE_51("rollover-with-pending-order", true),
    FEATURE_52("unopen-approve-invoice-reopen", true),
    FEATURE_53("unopen-order-and-add-addition-pol-and-check-encumbrances", true),
    FEATURE_54("unopen-order-simple-case", true),
    FEATURE_55("update-encumbrance-links-with-fiscal-year", true),
    FEATURE_56("update_fund_in_poline_when_invoice_approved", true);

    private final String fileName;
    private final boolean isEnabled;

    Feature(String fileName, boolean isEnabled) {
      this.fileName = fileName;
      this.isEnabled = isEnabled;
    }

    public String getFileName() {
      return fileName;
    }

    public boolean isEnabled() {
      return isEnabled;
    }
  }

  public CrossModulesApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void crossModuleApiTestBeforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/cross-modules/init-cross-modules.feature");
  }

  @AfterAll
  public void crossModuleApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void approveInvoiceUsingDifferentFiscalYears() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void approveInvoiceWithNegativeLine() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void auditEventInvoice() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void auditEventInvoiceLine() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void auditEventOrganization() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelInvoiceAndUnrelease2Encumbrances() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelInvoiceLinkedToOrder() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelInvoiceWithEncumbrance() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changeFdCheckInitialAmount() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changePolineFdAndPayInvoice() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkApproveAndPayInvoiceWithInvoiceReferencesSamePoLine() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEncumbranceStatusAfterMovingExpendedValue() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEncumbrancesAfterIssuingCreditForPaidOrder() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEncumbrancesAfterOrderIsReopened() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEncumbrancesAfterOrderIsReopened2() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEncumbrancesAfterOrderLineExchangeRateUpdate() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkOrderReEncumberAfterPreviewRollover() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkOrderTotalFieldsCalculatedCorrectly() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkPaymentStatusAfterCancellingPaidInvoice() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkPaymentStatusAfterReopen() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkPoNumbersUpdates() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkPoNumbersUpdatesWhenIinvoiceLineDeleted() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderAndApproveInvoiceWerePolWithoutFundDistributions() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderAndInvoiceWithOddPenny() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deleteEncumbrance() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void invoiceEncumbranceUpdateWithoutAcquisitionUnit() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerRollover() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloverCashBalance() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void linkInvoiceLineToPoLine() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deletePlannedBudgetWithoutTransactions() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void movingEncumberedValueToDifferentBudget() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void movingExpendedValueToNewlyCreatedEncumbrance() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openApproveAndPayOrderWith50Lines() {
    runFeatureTest(Feature.FEATURE_35.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderAfterApprovingInvoice() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderInvoiceRelation() {
    runFeatureTest(Feature.FEATURE_37.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderInvoiceRelationCanBeChanged() {
    runFeatureTest(Feature.FEATURE_38.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderInvoiceRelationCanBeDeleted() {
    runFeatureTest(Feature.FEATURE_39.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void order_invoice_relation_must_be_deleted_if_invoice_deleted() {
    runFeatureTest(Feature.FEATURE_40.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void partialRollover() {
    runFeatureTest(Feature.FEATURE_41.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void payInvoiceAndDeletePiece() {
    runFeatureTest(Feature.FEATURE_42.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void payInvoiceWithNewExpenseClass() {
    runFeatureTest(Feature.FEATURE_43.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void payInvoiceWithoutOrderAcqUnitPermission() {
    runFeatureTest(Feature.FEATURE_44.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pendingPaymentUpdateAfterEncumbranceDeletion() {
    runFeatureTest(Feature.FEATURE_45.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void removeFundDistributionAfterRolloverWhenReEncumberFalse() {
    runFeatureTest(Feature.FEATURE_46.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void removeLinkedInvoiceLinesFundDistributionEncumbranceReference() {
    runFeatureTest(Feature.FEATURE_47.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverAndPayInvoiceUsingPastFiscalYear() {
    runFeatureTest(Feature.FEATURE_48.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverWithClosedOrder() {
    runFeatureTest(Feature.FEATURE_49.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverWithNoSettings() {
    runFeatureTest(Feature.FEATURE_50.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverWithPendingOrder() {
    runFeatureTest(Feature.FEATURE_51.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopenApproveInvoiceReopen() {
    runFeatureTest(Feature.FEATURE_52.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopen_order_and_add_addition_pol_and_check_encumbrances() {
    runFeatureTest(Feature.FEATURE_53.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopen_order_simple_case() {
    runFeatureTest(Feature.FEATURE_54.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updateEncumbranceLinksWithFiscalYear() {
    runFeatureTest(Feature.FEATURE_55.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updateFundInPoLineWhenInvoiceApproved() {
    runFeatureTest(Feature.FEATURE_56.getFileName());
  }
}
