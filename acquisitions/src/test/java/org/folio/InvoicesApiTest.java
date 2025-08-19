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

@FolioTest(team = "thunderjet", module = "mod-invoice")
public class InvoicesApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-invoice/features/";

  public InvoicesApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void invoicesApiTestBeforeAll() {
    System.setProperty("testTenant", "testinvoice" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-invoice/init-invoice.feature");
  }

  @AfterAll
  public void invoicesApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }


  @Test
  void approveAndPayInvoiceWithPastFiscalYear() {
    runFeatureTest("approve-and-pay-invoice-with-past-fiscal-year");
  }

  @Test
  void batchVoucherExportWithManyLines() {
    runFeatureTest("batch-voucher-export-with-many-lines");
  }

  @Test
  void checkVendorAddressIncludedWithBatchVoucher() {
    runFeatureTest("batch-voucher-uploaded");
  }

  @Test
  void cancelInvoice() {
    runFeatureTest("cancel-invoice");
  }

  @Test
  void checkApproveAndPayInvoiceWithOddPenniesNumber() {
    runFeatureTest("check-approve-and-pay-invoice-with-odd-pennies-number");
  }

  @Test
  void checkApproveAndPayInvoiceWithZeroDollarAmount() {
    runFeatureTest("check-approve-and-pay-invoice-with-zero-dollar-amount");
  }

  @Test
  void checkErrorResponseWithFundCode() {
    runFeatureTest("check-error-respose-with-fundcode-upon-invoice-approval");
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() {
    runFeatureTest("check-invoice-and-invoice-lines-deletion-restrictions");
  }

  @Test
  void checkInvoiceFullFlowWhereSubTotalIsNegative() {
    runFeatureTest("check-invoice-full-flow-where-subTotal-is-negative");
  }

  @Test
  void checkInvoiceLinesAndDocumentsAreDeletedWithInvoice() {
    runFeatureTest("check-invoice-lines-and-documents-are-deleted-with-invoice");
  }

  @Test
  void checkInvoiceLinesWithVatAdjustments() {
    runFeatureTest("check-invoice-lines-with-vat-adjustments");
  }

  @Test
  void validateInvoiceWithAdjustment() {
    runFeatureTest("check-invoice-line-validation-with-adjustments");
  }

  @Test
  void checkLockTotalsAndCalculatedTotalsInInvoiceApproveTime() {
    runFeatureTest("check-lock-totals-and-calculated-totals-in-invoice-approve-time");
  }

  @Test
  void checkRemainingAmountInvoiceApproval() {
    runFeatureTest("check-remaining-amount-upon-invoice-approval");
  }

  @Test
  void checkThatCanNotApproveInvoiceIfOrganizationIsNotVendor() {
    runFeatureTest("check-that-can-not-approve-invoice-if-organization-is-not-vendor");
  }

  @Test
  void checkThatChangingProtectedFieldsForbiddenForApprovedInvoice() {
    runFeatureTest("check-that-changing-protected-fields-forbidden-for-approved-invoice");
  }

  @Test
  void checkThatNotPossibleAddInvoiceLineToApprovedInvoice() {
    runFeatureTest("check-that-not-possible-add-invoice-line-to-approved-invoice");
  }

  @Test
  void checkThatNotPossiblePayForInvoiceIfNoVoucher() {
    runFeatureTest("check-that-not-possible-pay-for-invoice-if-no-voucher");
  }

  @Test
  void checkThatNotPossiblePayForInvoiceWithoutApproved() {
    runFeatureTest("check-that-not-possible-pay-for-invoice-without-approved");
  }

  @Test
  void checkThatVoucherExistWithParameters() {
    runFeatureTest("check-that-voucher-exist-with-parameters");
  }

  @Test
  void createVoucherLinesExpenseClasses() {
    runFeatureTest("create-voucher-lines-honor-expense-classes");
  }

  @Test
  void editSubscriptionDatesAfterInvoicePaid() {
    runFeatureTest("edit-subscription-dates-after-invoice-paid");
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() {
    runFeatureTest("exchange-rate-update-after-invoice-approval");
  }

  @Test
  void expenseClassesValidation() {
    runFeatureTest("expense-classes-validation");
  }

  @Test
  void fiscalYearBalanceWithNegativeAvailable() {
    runFeatureTest("fiscal-year-balance-with-negative-available");
  }

  @Test
  void invoiceFiscalYears() {
    runFeatureTest("invoice-fiscal-years");
  }

  @Test
  void invoiceWithIdenticalAdjustments() {
    runFeatureTest("invoice-with-identical-adjustments");
  }

  @Test
  void InvoiceWithLockTotalsCalculatedTotals() {
    runFeatureTest("invoice-with-lock-totals-calculated-totals");
  }

  @Test
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest("prorated-adjustments-special-cases");
  }

  @Test
  void setInvoiceFiscalYearAutomatically() {
    runFeatureTest("set-invoice-fiscal-year-automatically");
  }

  @Test
  void shouldPopulateVendorAddressWhenGetVoucherById() {
    runFeatureTest("should_populate_vendor_address_on_get_voucher_by_id");
  }

  @Test
  void voucherNumbers() {
    runFeatureTest("voucher-numbers");
  }

  @Test
  void voucherWithLinesUsingSameExternalAccount() {
    runFeatureTest("voucher-with-lines-using-same-external-account");
  }
}
