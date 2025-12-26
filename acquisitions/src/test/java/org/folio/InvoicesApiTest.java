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
  private static final String TEST_TENANT = "testinvoice";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("approve-and-pay-invoice-with-past-fiscal-year", true),
    FEATURE_2("batch-voucher-export-with-many-lines", true),
    FEATURE_3("batch-voucher-uploaded", true),
    FEATURE_4("cancel-invoice", true),
    FEATURE_5("check-approve-and-pay-invoice-with-odd-pennies-number", true),
    FEATURE_6("check-approve-and-pay-invoice-with-zero-dollar-amount", true),
    FEATURE_7("check-error-respose-with-fundcode-upon-invoice-approval", true),
    FEATURE_8("check-invoice-and-invoice-lines-deletion-restrictions", true),
    FEATURE_9("check-invoice-full-flow-where-subTotal-is-negative", true),
    FEATURE_10("check-invoice-lines-and-documents-are-deleted-with-invoice", true),
    FEATURE_11("check-invoice-lines-with-vat-adjustments", true),
    FEATURE_12("check-invoice-line-validation-with-adjustments", true),
    FEATURE_13("check-lock-totals-and-calculated-totals-in-invoice-approve-time", true),
    FEATURE_14("check-remaining-amount-upon-invoice-approval", true),
    FEATURE_15("check-that-can-not-approve-invoice-if-organization-is-not-vendor", true),
    FEATURE_16("check-that-changing-protected-fields-forbidden-for-approved-invoice", true),
    FEATURE_17("check-that-not-possible-add-invoice-line-to-approved-invoice", true),
    FEATURE_18("check-that-not-possible-pay-for-invoice-if-no-voucher", true),
    FEATURE_19("check-that-not-possible-pay-for-invoice-without-approved", true),
    FEATURE_20("check-that-voucher-exist-with-parameters", true),
    FEATURE_21("create-voucher-lines-honor-expense-classes", true),
    FEATURE_22("edit-subscription-dates-after-invoice-paid", true),
    FEATURE_23("exchange-rate-update-after-invoice-approval", true),
    FEATURE_24("expense-classes-validation", true),
    FEATURE_25("fiscal-year-balance-with-negative-available", true),
    FEATURE_26("invoice-fiscal-years", true),
    FEATURE_27("invoice-with-identical-adjustments", true),
    FEATURE_28("invoice-with-lock-totals-calculated-totals", true),
    FEATURE_29("prorated-adjustments-special-cases", true),
    FEATURE_30("set-invoice-fiscal-year-automatically", true),
    FEATURE_31("should_populate_vendor_address_on_get_voucher_by_id", true),
    FEATURE_32("voucher-numbers", true),
    FEATURE_33("voucher-with-lines-using-same-external-account", true);

    private final String fileName;
    private final boolean isEnabled;

    Feature(String fileName, boolean isEnabled) {
      this.fileName = fileName;
      this.isEnabled = isEnabled;
    }

    public boolean isEnabled() {
      return isEnabled;
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
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-invoice/init-invoice.feature");
  }

  @AfterAll
  public void invoicesApiTestAfterAll() {
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
  void approveAndPayInvoiceWithPastFiscalYear() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void batchVoucherExportWithManyLines() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void batchVoucherUploaded() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelInvoice() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkApproveAndPayInvoiceWithOddPenniesNumber() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkApproveAndPayInvoiceWithZeroDollarAmount() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkErrorResposeWithFundCodeUponInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkInvoiceAndInvoiceLinesDeletionRestrictions() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkInvoiceFullFlowWhereSubTotalIsNegative() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkInvoiceLinesAndDocumentsAreDeletedWithInvoice() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkInvoiceLinesWithVatAdjustments() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkInvoiceLineValidationWithAdjustments() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkLockTotalsAndCalculatedTotalsInInvoiceApproveTime() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkRemainingAmountUponInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatCanNotApproveInvoiceIfOrganizationIsNotVendor() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatChangingProtectedFieldsForbiddenForApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatNotPossibleAddInvoiceLineToApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatNotPossiblePayForInvoiceIfNoVoucher() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatNotPossiblePayForInvoiceWithoutApproved() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkThatVoucherExistWithParameters() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createVoucherLinesHonorExpenseClasses() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void editSubscriptionDatesAfterInvoicePaid() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void exchangeRateUpdateAfterInvoiceApproval() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void expenseClassesValidation() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fiscalYearBalanceWithNegativeAvailable() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void invoiceFiscalYears() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void invoiceWithIdenticalAdjustments() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void invoiceWithLockTotalsCalculatedTotals() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void setInvoiceFiscalYearAutomatically() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void shouldPopulateVendorAddressOnGetVoucherById() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void voucherNumbers() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void voucherWithLinesUsingSameExternalAccount() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }
}
