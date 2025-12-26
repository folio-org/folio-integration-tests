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

@FolioTest(team = "thunderjet", module = "mod-invoice")
public class InvoicesApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-invoice/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("approve-and-pay-invoice-with-past-fiscal-year"),
    FEATURE_2("batch-voucher-export-with-many-lines"),
    FEATURE_3("batch-voucher-uploaded"),
    FEATURE_4("cancel-invoice"),
    FEATURE_5("check-approve-and-pay-invoice-with-odd-pennies-number"),
    FEATURE_6("check-approve-and-pay-invoice-with-zero-dollar-amount"),
    FEATURE_7("check-error-respose-with-fundcode-upon-invoice-approval"),
    FEATURE_8("check-invoice-and-invoice-lines-deletion-restrictions"),
    FEATURE_9("check-invoice-full-flow-where-subTotal-is-negative"),
    FEATURE_10("check-invoice-lines-and-documents-are-deleted-with-invoice"),
    FEATURE_11("check-invoice-lines-with-vat-adjustments"),
    FEATURE_12("check-invoice-line-validation-with-adjustments"),
    FEATURE_13("check-lock-totals-and-calculated-totals-in-invoice-approve-time"),
    FEATURE_14("check-remaining-amount-upon-invoice-approval"),
    FEATURE_15("check-that-can-not-approve-invoice-if-organization-is-not-vendor"),
    FEATURE_16("check-that-changing-protected-fields-forbidden-for-approved-invoice"),
    FEATURE_17("check-that-not-possible-add-invoice-line-to-approved-invoice"),
    FEATURE_18("check-that-not-possible-pay-for-invoice-if-no-voucher"),
    FEATURE_19("check-that-not-possible-pay-for-invoice-without-approved"),
    FEATURE_20("check-that-voucher-exist-with-parameters"),
    FEATURE_21("create-voucher-lines-honor-expense-classes"),
    FEATURE_22("edit-subscription-dates-after-invoice-paid"),
    FEATURE_23("exchange-rate-update-after-invoice-approval"),
    FEATURE_24("expense-classes-validation"),
    FEATURE_25("fiscal-year-balance-with-negative-available"),
    FEATURE_26("invoice-fiscal-years"),
    FEATURE_27("invoice-with-identical-adjustments"),
    FEATURE_28("invoice-with-lock-totals-calculated-totals"),
    FEATURE_29("prorated-adjustments-special-cases"),
    FEATURE_30("set-invoice-fiscal-year-automatically"),
    FEATURE_31("should_populate_vendor_address_on_get_voucher_by_id"),
    FEATURE_32("voucher-numbers"),
    FEATURE_33("voucher-with-lines-using-same-external-account");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

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
  @DisplayName("(Thunderjet) Run features")
  @EnabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void approveAndPayInvoiceWithPastFiscalYear() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void batchVoucherExportWithManyLines() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void batchVoucherUploaded() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelInvoice() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkApproveAndPayInvoiceWithOddPenniesNumber() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkApproveAndPayInvoiceWithZeroDollarAmount() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkErrorResposeWithFundCodeUponInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkInvoiceAndInvoiceLinesDeletionRestrictions() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkInvoiceFullFlowWhereSubTotalIsNegative() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkInvoiceLinesAndDocumentsAreDeletedWithInvoice() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkInvoiceLinesWithVatAdjustments() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkInvoiceLineValidationWithAdjustments() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkLockTotalsAndCalculatedTotalsInInvoiceApproveTime() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkRemainingAmountUponInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatCanNotApproveInvoiceIfOrganizationIsNotVendor() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatChangingProtectedFieldsForbiddenForApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatNotPossibleAddInvoiceLineToApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatNotPossiblePayForInvoiceIfNoVoucher() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatNotPossiblePayForInvoiceWithoutApproved() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkThatVoucherExistWithParameters() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createVoucherLinesHonorExpenseClasses() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void editSubscriptionDatesAfterInvoicePaid() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void exchangeRateUpdateAfterInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void expenseClassesValidation() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void fiscalYearBalanceWithNegativeAvailable() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void invoiceFiscalYears() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void invoiceWithIdenticalAdjustments() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void invoiceWithLockTotalsCalculatedTotals() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void setInvoiceFiscalYearAutomatically() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void shouldPopulateVendorAddressOnGetVoucherById() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void voucherNumbers() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void voucherWithLinesUsingSameExternalAccount() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }
}
