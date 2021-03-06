package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InvoicesApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-invoice/features/";

  public InvoicesApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() {
    runFeatureTest("check-invoice-and-invoice-lines-deletion-restrictions");
  }

  @Test
  void checkInvoiceLinesAndDocumentsAreDeletedWithInvoice() {
    runFeatureTest("check-invoice-lines-and-documents-are-deleted-with-invoice");
  }

  @Test
  void checkRemainingAmountInvoiceApproval() {
    runFeatureTest("check-remaining-amount-upon-invoice-approval");
  }

  @Test
  void createVoucherLinesExpenseClasses() {
    runFeatureTest("create-voucher-lines-honor-expense-classes");
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() {
    runFeatureTest("exchange-rate-update-after-invoice-approval");
  }

  @Test
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest("prorated-adjustments-special-cases");
  }

  @Test
  void InvoiceWithLockTotalsCalculatedTotals() {
    runFeatureTest("invoice-with-lock-totals-calculated-totals");
  }

  @Test
   void checkLockTotalsAndCalculatedTotalsInInvoiceApproveTime() {
    runFeatureTest("check-lock-totals-and-calculated-totals-in-invoice-approve-time.feature");
  }

  @Test
  void checkThatChangingProtectedFieldsForbiddenForApprovedInvoice() {
    runFeatureTest("check-that-changing-protected-fields-forbidden-for-approved-invoice.feature");
  }

  @Test
  void checkThatNotPossibleAddInvoiceLineToApprovedInvoice() {
    runFeatureTest("check-that-not-possible-add-invoice-line-to-approved-invoice.feature");
  }

  @Test
  void checkThatNotPossiblePayForInvoiceIfNoVoucher() {
    runFeatureTest("check-that-not-possible-pay-for-invoice-if-no-voucher.feature");
  }

  @Test
  void checkVendorAddressIncludedWithBatchVoucher() {
    runFeatureTest("check-vendor-address-included-with-batch-voucher.feature");
  }

  @Test
  void checkInvoiceFullFlowWhereSubTotalIsNegative() {
    runFeatureTest("check-invoice-full-flow-where-subTotal-is-negative.feature");
  }

  @Test
  void voucherWithLinesUsingSameExternalAccount() {
    runFeatureTest("voucher-with-lines-using-same-external-account.feature");
  }

  @Test
  void shouldPopulateVendorAddressWhenGetVoucherById() {
    runFeatureTest("should_populate_vendor_address_on_get_voucher_by_id.feature");
  }

  @Test
  void checkApproveAndPayInvoiceWithOddPenniesNumber() {
    runFeatureTest("check-approve-and-pay-invoice-with-odd-pennies-number.feature");
  }

  @Test
  void checkThatCanNotApproveInvoiceIfOrganizationIsNotVendor() {
    runFeatureTest("check-that-can-not-approve-invoice-if-organization-is-not-vendor.feature");
  }

  @BeforeAll
  public void invoicesApiTestBeforeAll() {
    runFeature("classpath:domain/mod-invoice/invoice-junit.feature");
  }

  @AfterAll
  public void invoicesApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
