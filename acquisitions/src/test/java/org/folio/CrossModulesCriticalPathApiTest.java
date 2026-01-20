package org.folio;

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

@Order(7)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesCriticalPathApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("unrelease-encumbrances-when-reopen-ongoing-order-with-related-paid-invoice-and-receiving", true),
    FEATURE_2("encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice", true),
    FEATURE_3("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice", true),
    FEATURE_4("encumbrance-remains-0-for-re-opened-0-dollar-ongoing-order-with-paid-invoice", true),
    FEATURE_5("encumbrance-remains-same-after-cancelling-credited-invoice", true),
    FEATURE_6("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-and-credited-invoices", true),
    FEATURE_7("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-and-canceling-credited-invoice", true),
    FEATURE_8("encumbrance-remains-0-for-reopened-one-time-order-with-approved-invoice-unreleasing-and-canceling-invoice", true),
    FEATURE_9("encumbrance-remains-same-after-cancelling-credit-invoice-with-another-paid-invoice", true),
    FEATURE_10("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-credit-and-paid-invoices-release-true", true),
    FEATURE_11("encumbrance-updates-correctly-after-canceling-first-of-two-paid-invoices", true),
    FEATURE_12("encumbrance-unreleased-after-cancelling-invoice-and-reopening-order", true),
    FEATURE_13("encumbrance-calculated-correctly-after-canceling-invoice-with-other-paid-and-credit-invoices", true),
    FEATURE_14("encumbrance-calculated-correctly-after-canceling-approved-invoice-with-other-invoices-release-false", true),
    FEATURE_15("encumbrance-unreleased-after-cancelling-approved-invoice-and-re-opening-order-release-false", true),
    FEATURE_16("encumbrance-calculated-correctly-after-canceling-approved-invoice-exceeding-initial-encumbrance-release-false", true),
    FEATURE_17("encumbrance-remains-same-after-cancelling-credited-approved-invoice-release-false", true),
    FEATURE_18("encumbrance-after-removing-fund-distribution-from-pol.feature", true),
    FEATURE_19("encumbrance-released-after-manual-release-and-fund-change-ongoing", true),
    FEATURE_20("encumbrance-released-after-fund-change-with-paid-invoice-release-true", true),
    FEATURE_21("encumbrance-released-after-manual-release-and-fund-change-with-paid-invoice-release-false", true),
    FEATURE_22("budget-and-encumbrance-updated-correctly-after-editing-pol-with-invoice-after-rollover", true),
    FEATURE_23("cancel-paid-invoice-after-changing-fund-distribution", true),
    FEATURE_24("subscription-and-tags-editable-in-paid-invoice-after-rollover-with-closed-budget", true),
    FEATURE_25("subscription-and-tags-editable-in-approved-invoice-with-inactive-budget", true),
    FEATURE_26("encumbrance-remains-unreleased-after-expense-class-change-with-paid-invoice", true),
    FEATURE_27("encumbrance-and-budget-updated-correctly-after-editing-fund-distribution-and-increasing-cost-with-paid-invoice", true),
    FEATURE_28("fund-distribution-can-be-changed-after-rollover-when-re-encumber-not-active", true),
    FEATURE_29("encumbrance-released-after-expense-class-change-in-pol-and-invoice-with-paid-invoice", true);

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

  public CrossModulesCriticalPathApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void crossModuleCriticalPathApiTestBeforeAll() {
    SharedCrossModulesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  public void crossModulesCriticalPathApiTestAfterAll() {
    SharedCrossModulesTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C356782, C356412, C358532, C356785) Unrelease Encumbrances When Reopen Ongoing Order With Related Paid Invoice And Receiving")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unreleaseEncumbrancesWhenReopenOngoingOrderWithRelatedPaidInvoiceAndReceiving() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844257) Encumbrance Calculated Correctly For A Un-Opened Ongoing Order With An Approved Invoice And After Canceling An Approved Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyForUnopenedOngoingOrderWithApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C825437) Encumbrance Remains 0 For A 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoice() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C829881) Encumbrance Remains 0 For A Re-Opened 0 Dollar Ongoing Order With A Paid Invoice Unreleasing Encumbrance And Canceling A Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0ForReOpened0DollarOngoingOrderWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C852110) Encumbrance Remains The Same After Cancelling A Credited Paid Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditedInvoice() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844264) Encumbrance Remains 0 For An 0 Dollar Ongoing Order When Paid And Credited Invoices Exist And After Invoices Cancelation Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidAndCreditedInvoices() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844254) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Credited Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoiceUnreleasingAndCancelingCreditedInvoice() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844262) Encumbrance Remains 0 For A Re-Opened One-Time Order With An Approved Invoice Unreleasing Encumbrance And Canceling An Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0ForReopenedOneTimeOrderWithApprovedInvoiceUnreleasingAndCancelingInvoice() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C400618) Initial Encumbrance Amount Remains The Same As It Was Before Payment After Cancelling Related Paid Credit Invoice Another Related Paid Invoice Exists")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditInvoiceWithAnotherPaidInvoice() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C864744) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Credit Invoice And Canceling Another Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingCreditAndPaidInvoicesReleaseTrue() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C870004) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUpdatesCorrectlyAfterCancelingFirstOfTwoPaidInvoices() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877072) Encumbrance Is Unreleased After Cancelling The Related Paid Invoice And Re-Opening The Order Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUnreleasedAfterCancellingInvoiceAndReopeningOrder() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877073) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice When Other Paid And Credit Invoices Exist Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingInvoiceWithOtherPaidAndCreditInvoices() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889715) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice When Other Approved And Credit Invoices Exist Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceWithOtherInvoicesReleaseFalse() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889716) Encumbrance Is Unreleased After Cancelling The Related Approved Invoice And Re-Opening The Order Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUnreleasedAfterCancellingApprovedInvoiceAndReOpeningOrderReleaseFalse() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889714) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceExceedingInitialEncumbranceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889713) Encumbrance Remains The Same After Cancelling A Credited Approved Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditedApprovedInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C926164) Fund Distribution Can Be Removed From POL After Cancelling All Related Invoices And Reopening Order")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fundDistributionCanBeRemovedFromPolAfterCancellingAllRelatedInvoicesAndReopeningOrder() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877086) Encumbrance Is Created As Released After Releasing It Manually And Changing The Fund Distribution")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterManualReleaseAndFundChangeOngoing() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877085) Encumbrance Is Created As Released After Changing The Fund Distribution With Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterFundChangeWithPaidInvoiceReleaseTrue() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C877084) Encumbrance Is Created As Released After Manual Release And Fund Change With Paid Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterManualReleaseAndFundChangeWithPaidInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C357580) Budget Summary And Encumbrances Updated Correctly When Editing POL With Related Invoice After Rollover Of Fiscal Year")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetAndEncumbranceUpdatedCorrectlyAfterEditingPolWithInvoiceAfterRollover() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }
  
  @Test
  @DisplayName("(Thunderjet) (C895660) Cancel A Paid Invoice After Changing Fund Distribution In The PO Line")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelPaidInvoiceAfterChangingFundDistribution() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C919908) Subscription Info, Tags, And Comments Can Be Edited In A Paid Invoice When The Fund's Budget From Prior FY Is Closed")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void subscriptionAndTagsEditableInPaidInvoiceAfterRolloverWithClosedBudget() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C919907) Subscription Info, Tags, And Comments Can Be Edited In An Approved Invoice When The Fund's Budget Is Set To Inactive")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void subscriptionAndTagsEditableInApprovedInvoiceWithInactiveBudget() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C700837, C710243) Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsUnreleasedAfterExpenseClassChangeWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C375290) Encumbrance And Budget Updated Correctly After Editing Fund Distribution And Increasing Cost With Paid Invoice")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceAndBudgetUpdatedCorrectlyAfterEditingFundDistributionAndIncreasingCostWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C451636) Fund Distribution Can Be Changed After Rollover When Re-Encumber Is Not Active")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fundDistributionCanBeChangedAfterRolloverWhenReEncumberNotActive() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C722381) Encumbrance Released After Expense Class Change In POL And Invoice With Paid Invoice")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterExpenseClassChangeInPolAndInvoiceWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }
}
