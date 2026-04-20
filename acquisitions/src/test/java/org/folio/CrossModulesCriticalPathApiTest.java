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

@Order(8)
@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesCriticalPathApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";
  private static final String TEST_TENANT = "testcross";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice", true),
    FEATURE_2("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice", true),
    FEATURE_3("encumbrance-remains-0-for-re-opened-0-dollar-ongoing-order-with-paid-invoice", true),
    FEATURE_4("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-and-credited-invoices", true),
    FEATURE_5("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-and-canceling-credited-invoice", true),
    FEATURE_6("encumbrance-remains-0-for-reopened-one-time-order-with-approved-invoice-unreleasing-and-canceling-invoice", true),
    FEATURE_7("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-credit-and-paid-invoices-release-true", true),
    FEATURE_8("encumbrance-calculated-correctly-after-canceling-approved-invoice-exceeding-initial-encumbrance-release-false", true),
    FEATURE_9("encumbrance-remains-same-after-cancelling-credited-approved-invoice-release-false", true),
    FEATURE_10("cancel-paid-invoice-after-changing-fund-distribution", true),
    FEATURE_11("encumbrance-remains-unreleased-after-expense-class-change-with-paid-invoice-release-true", true),
    FEATURE_12("encumbrance-and-budget-updated-correctly-after-editing-fund-distribution-and-increasing-cost-with-paid-invoice", true),
    FEATURE_13("encumbrance-released-after-expense-class-change-in-pol-and-invoice-with-paid-invoice", true),
    FEATURE_14("total-expended-no-encumbrances", true),
    FEATURE_15("total-expended-different-fiscal-years", true),
    FEATURE_16("total-expended-no-paid-invoices", true),
    FEATURE_17("total-expended-different-fund-distributions", true),
    FEATURE_18("encumbrance-after-canceling-paid-invoice-with-other-paid-invoices-release-false", true),
    FEATURE_19("encumbrance-after-canceling-approved-invoice-with-other-approved-invoices-release-false", true),
    FEATURE_20("encumbrance-after-canceling-paid-invoice-with-mixed-release-settings", true),
    FEATURE_21("encumbrance-after-canceling-approved-invoice-with-mixed-release-settings", true),
    FEATURE_22("rollover-two-ledgers-with-multi-fund-pol", true),
    FEATURE_23("rollover-three-ledgers-with-expense-classes-twice", true),
    FEATURE_24("rollover-three-ledgers-with-different-fund-distributions", true);

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
  @Override
  public void beforeAll() {
    SharedCrossModulesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    destroyTenant();
  }

  @Test
  @DisplayName("(Thunderjet) Destroy tenant")
  @EnabledIfSystemProperty(named = "destroy", matches = "true")
  public void destroyTenantManually() {
    destroyTenant();
  }

  @Override
  public void destroyTenant() {
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
  @DisplayName("(Thunderjet) (C844257) Encumbrance Calculated Correctly For A Un-Opened Ongoing Order With An Approved Invoice And After Canceling An Approved Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyForUnopenedOngoingOrderWithApprovedInvoice() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C825437) Encumbrance Remains 0 For A 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoice() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C829881) Encumbrance Remains 0 For A Re-Opened 0 Dollar Ongoing Order With A Paid Invoice Unreleasing Encumbrance And Canceling A Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0ForReOpened0DollarOngoingOrderWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844264) Encumbrance Remains 0 For An 0 Dollar Ongoing Order When Paid And Credited Invoices Exist And After Invoices Cancelation Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidAndCreditedInvoices() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844254) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Credited Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoiceUnreleasingAndCancelingCreditedInvoice() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C844262) Encumbrance Remains 0 For A Re-Opened One-Time Order With An Approved Invoice Unreleasing Encumbrance And Canceling An Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0ForReopenedOneTimeOrderWithApprovedInvoiceUnreleasingAndCancelingInvoice() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C864744) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Credit Invoice And Canceling Another Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingCreditAndPaidInvoicesReleaseTrue() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889714) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceExceedingInitialEncumbranceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C889713) Encumbrance Remains The Same After Cancelling A Credited Approved Invoice Release Encumbrance False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsSameAfterCancellingCreditedApprovedInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C895660) Cancel A Paid Invoice After Changing Fund Distribution In The PO Line")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelPaidInvoiceAfterChangingFundDistribution() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C700837) Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice Release Encumbrance True")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceRemainsUnreleasedAfterExpenseClassChangeWithPaidInvoiceReleaseTrue() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C375290) Encumbrance And Budget Updated Correctly After Editing Fund Distribution And Increasing Cost With Paid Invoice")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceAndBudgetUpdatedCorrectlyAfterEditingFundDistributionAndIncreasingCostWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C722381) Encumbrance Released After Expense Class Change In POL And Invoice With Paid Invoice")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedAfterExpenseClassChangeInPolAndInvoiceWithPaidInvoice() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C594371) Total Expended Amount Calculation When Order Has No Encumbrances")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedNoEncumbrances() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C594372) Total Expended Amount Calculation With Paid Invoices From Different Fiscal Years")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedDifferentFiscalYears() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C610241) Total Expended Amount Calculation With No Encumbrances And No Related Paid Invoices")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedNoPaidInvoices() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C605930) Total Expended Amount Calculation With Different Fund Distributions")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void totalExpendedDifferentFundDistributions() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1028985) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice When Other Paid Invoices Exist Release False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingPaidInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1028984) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice When Other Approved Invoices Exist Release False")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceReleaseFalse() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1028981) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice Release False When Another Paid Invoice Release True Exists")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingPaidInvoiceWithMixedReleaseSettings() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1028980) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice Release False When Another Approved Invoice Release True Exists")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceWithMixedReleaseSettings() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C987716) Encumbrances Are Rollovered Correctly When PO Lines Contain Fund Distributions Related To Two Different Ledgers And Same Fiscal Year")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverTwoLedgersWithMultiFundPol() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C987717) Encumbrances Are Rollovered Correctly When PO Lines Contain Fund Distributions Related To Three Different Ledgers And Same Fiscal Year")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverThreeLedgersWithExpenseClassesTwice() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C987720) Encumbrances Are Rollovered Correctly When PO Lines Contain Different Fund Distributions Related To Three Different Ledgers And Same Fiscal Year")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void rolloverThreeLedgersWithDifferentFundDistributions() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }
}
