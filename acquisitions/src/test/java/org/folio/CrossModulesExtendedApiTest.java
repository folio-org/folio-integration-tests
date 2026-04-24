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
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@Order(9)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("total-expended-with-fund-distribution-and-encumbrance", true),
    FEATURE_2("budget-summary-when-amounts-exceed-available", true),
    FEATURE_3("budget-summary-encumbered-approved-paid-exceed-available", true),
    FEATURE_4("budget-summary-transfer-decreases-below-available", true),
    // moved from CrossModulesCriticalPathApiTest (TestRail group = Extended)
    FEATURE_5("budget-and-encumbrance-updated-correctly-after-editing-pol-with-invoice-after-rollover", true),
    FEATURE_6("unrelease-encumbrances-when-reopen-ongoing-order-with-related-paid-invoice-and-receiving", true),
    FEATURE_7("rollover-based-on-expended-with-credit-invoice", true),
    FEATURE_8("encumbrance-remains-same-after-cancelling-credited-invoice", true),
    FEATURE_9("encumbrance-remains-same-after-cancelling-credit-invoice-with-another-paid-invoice", true),
    FEATURE_10("encumbrance-updates-correctly-after-canceling-first-of-two-paid-invoices", true),
    FEATURE_11("encumbrance-unreleased-after-cancelling-invoice-and-reopening-order", true),
    FEATURE_12("encumbrance-calculated-correctly-after-canceling-invoice-with-other-paid-and-credit-invoices", true),
    FEATURE_13("encumbrance-calculated-correctly-after-canceling-approved-invoice-with-other-invoices-release-false", true),
    FEATURE_14("encumbrance-unreleased-after-cancelling-approved-invoice-and-re-opening-order-release-false", true),
    FEATURE_15("encumbrance-after-removing-fund-distribution-from-pol", true),
    FEATURE_16("encumbrance-released-after-manual-release-and-fund-change-ongoing", true),
    FEATURE_17("encumbrance-released-after-fund-change-with-paid-invoice-release-true", true),
    FEATURE_18("encumbrance-released-after-manual-release-and-fund-change-with-paid-invoice-release-false", true),
    FEATURE_19("subscription-and-tags-editable-in-paid-invoice-after-rollover-with-closed-budget", true),
    FEATURE_20("subscription-and-tags-editable-in-approved-invoice-with-inactive-budget", true),
    FEATURE_21("fund-distribution-can-be-changed-after-rollover-when-re-encumber-not-active", true),
    // moved from CrossModulesCriticalPathApiTest (TestRail group = Extended)
    FEATURE_22("encumbrance-remains-unreleased-after-expense-class-change-with-paid-invoice-release-false", true),
    FEATURE_23("over-encumbrance-for-fy-ledger-and-group", true);

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

  public CrossModulesExtendedApiTest() {
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
    SharedCrossModulesTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @Override
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  public void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C594417) Total Expended Amount Calculation With Fund Distribution And Encumbrance")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedWithFundDistributionAndEncumbrance() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496145) Correct Financial Summary Values When Approved And Paid Amounts Exceed Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenAmountsExceedAvailable() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496149) Correct Financial Summary Values When Encumbered Approved And Paid Amounts Exceed Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenEncumberedApprovedAndPaidExceedAvailable() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496153) Correct Financial Summary Values When Decrease Allocation Exceeds Available Amount")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetSummaryWhenDecreaseAllocationExceedsAvailable() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  // --- moved from CrossModulesCriticalPathApiTest ---

  @Test
  @DisplayName("(Thunderjet) (C357580) Budget Summary And Encumbrances Updated Correctly When Editing POL With Related Invoice After Rollover Of Fiscal Year")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetAndEncumbranceUpdatedCorrectlyAfterEditingPolWithInvoiceAfterRollover() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C356782, C356412, C358532, C356785) Unrelease Encumbrances When Reopen Ongoing Order With Related Paid Invoice And Receiving")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unreleaseEncumbrancesWhenReopenOngoingOrderWithRelatedPaidInvoiceAndReceiving() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C503142) Rollover Based On Expended When Credit Invoice Exists")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverBasedOnExpendedWithCreditInvoice() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  // --- moved from CrossModulesCriticalPathApiTest (TestRail group = Extended) ---

  @Test
  @DisplayName("(Thunderjet) (C852110) Encumbrance Remains The Same After Cancelling A Credited Paid Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditedInvoice() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C400618) Initial Encumbrance Amount Remains The Same As It Was Before Payment After Cancelling Related Paid Credit Invoice Another Related Paid Invoice Exists")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditInvoiceWithAnotherPaidInvoice() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C870004) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUpdatesCorrectlyAfterCancelingFirstOfTwoPaidInvoices() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877072) Encumbrance Is Unreleased After Cancelling The Related Paid Invoice And Re-Opening The Order Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUnreleasedAfterCancellingInvoiceAndReopeningOrder() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877073) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice When Other Paid And Credit Invoices Exist Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingInvoiceWithOtherPaidAndCreditInvoices() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889715) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice When Other Approved And Credit Invoices Exist Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceWithOtherInvoicesReleaseFalse() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889716) Encumbrance Is Unreleased After Cancelling The Related Approved Invoice And Re-Opening The Order Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUnreleasedAfterCancellingApprovedInvoiceAndReOpeningOrderReleaseFalse() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C926164) Fund Distribution Can Be Removed From POL After Cancelling All Related Invoices And Reopening Order")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fundDistributionCanBeRemovedFromPolAfterCancellingAllRelatedInvoicesAndReopeningOrder() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877086) Encumbrance Is Created As Released After Releasing It Manually And Changing The Fund Distribution")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterManualReleaseAndFundChangeOngoing() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877085) Encumbrance Is Created As Released After Changing The Fund Distribution With Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterFundChangeWithPaidInvoiceReleaseTrue() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877084) Encumbrance Is Created As Released After Manual Release And Fund Change With Paid Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterManualReleaseAndFundChangeWithPaidInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C919908) Subscription Info, Tags, And Comments Can Be Edited In A Paid Invoice When The Fund's Budget From Prior FY Is Closed")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void subscriptionAndTagsEditableInPaidInvoiceAfterRolloverWithClosedBudget() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C919907) Subscription Info, Tags, And Comments Can Be Edited In An Approved Invoice When The Fund's Budget Is Set To Inactive")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void subscriptionAndTagsEditableInApprovedInvoiceWithInactiveBudget() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C451636) Fund Distribution Can Be Changed After Rollover When Re-Encumber Is Not Active")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fundDistributionCanBeChangedAfterRolloverWhenReEncumberNotActive() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C710243) Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsUnreleasedAfterExpenseClassChangeWithPaidInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C496175) Over Encumbrance Is Calculated Correctly For Fiscal Year Ledger And Group")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void overEncumbranceCalculatedCorrectlyForFiscalYearLedgerAndGroup() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }
}
