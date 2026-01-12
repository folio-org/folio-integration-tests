package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@Order(8)
@FolioTest(team = "thunderjet", module = "mod-finance")
public class FinanceApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-finance/features/";
  private static final String TEST_TENANT = "testfinance";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("allowable-encumbrance-and-expenditure-restrictions", true),
    FEATURE_2("batch-transaction-api", true),
    FEATURE_3("budget-and-fund-optimistic-locking", true),
    FEATURE_4("budget-can-be-deleted-if-have-only-allocation-transactions-from-or-to", true),
    FEATURE_5("budget-can-not-be-deleted-if-have-other-than-allocation-transactions", true),
    FEATURE_6("budget-can-not-be-deleted-if-have-to-and-from-fund-in-allocation-transactions", true),
    FEATURE_7("budget-expense-classes", true),
    FEATURE_8("budgets-totals-calculation", true),
    FEATURE_9("budget-transfer-transactions", true),
    FEATURE_10("budget-update", true),
    FEATURE_11("create-planned-budget-without-expense-classes-and-current-budget", true),
    FEATURE_12("create-planned-budget-without-expense-classes-when-there-is-no-current-budget", true),
    FEATURE_13("current-budget-for-fund", true),
    FEATURE_14("curr-fiscal-year-for-ledger-consider-time-zone", false),
    FEATURE_15("finance-data", true),
    FEATURE_16("fiscal-year-totals", true),
    FEATURE_17("group-and-ledger-transfers-after-rollover", true),
    FEATURE_18("group-expense-classes", true),
    FEATURE_19("group-fiscal-year-totals", true),
    FEATURE_20("ledger-fiscal-year-preview-rollover", true),
    FEATURE_21("ledger-fiscal-year-preview-rollover-need-close-budgets", true),
    FEATURE_22("ledger-fiscal-year-rollover-fail-resistance-when-duplicate-encumbrance", true),
    FEATURE_23("ledger-fiscal-year-rollover-MODFISTO-247", true),
    FEATURE_24("ledger-fiscal-year-rollover-order-with-broken-encumbrance", true),
    FEATURE_25("ledger-fiscal-year-rollover-pol-and-system-currencies-are-different", true),
    FEATURE_26("ledger-fiscal-year-rollovers-multiple", true),
    FEATURE_27("ledger-fiscal-year-sequential-rollovers", true),
    FEATURE_28("ledger-fiscal-year-skip-previous-year-encumbrance", true),
    FEATURE_29("ledger-totals", true),
    FEATURE_30("unopen-order-after-rollover-MODORDERS-542", false),
    FEATURE_31("unrelease-encumbrance", true),
    FEATURE_32("update-encumbrance-transactions", true),
    FEATURE_33("acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units", true),
    FEATURE_34("acq-units/verify-get-funds-with-query-where-user-has-units", true),
    FEATURE_35("when-creating-budget-add-expense-classes-from-previous-budget-automatically", true),
    FEATURE_36("when-creating-budget-add-expense-classes-if-them-provided-by-user", true);

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

  public FinanceApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void financeApiTestBeforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-finance/init-finance.feature");
  }

  @AfterAll
  public void financeApiTestAfterAll() {
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
  void allowableEncumbranceAndExpenditureRestrictions() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void batchTransactionApi() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetAndFundOptimisticLocking() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetCanBeDeletedIfHaveOnlyAllocationTransactionsFromOrTo() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetCanNotBeDeletedIfHaveOtherThanAllocationTransactions() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetCanNotBeDeletedIfHaveToAndFromFundInAllocationTransactions() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetExpenseClasses() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetsTotalsCalculation() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetTransferTransactions() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void budgetUpdate() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createPlannedBudgetWithoutExpenseClassesAndCurrentBudget() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createPlannedBudgetWithoutExpenseClassesWhenThereIsNoCurrentBudget() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void currentBudgetForFund() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @Disabled
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void currFiscalYearForLedgerConsiderTimeZone() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void financeData() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fiscalYearTotals() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void groupAndLedgerTransfersAfterRollover() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void groupExpenseClasses() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void groupFiscalYearTotals() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearPreviewRollover() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearPreviewRolloverNeedCloseBudgets() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloverFailResistanceWhenDuplicateEncumbrance() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloverMODFISTO247() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloverOrderWithBrokenEncumbrance() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloverPolAndSystemCurrenciesAreDifferent() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearRolloversMultiple() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearSequentialRollovers() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerFiscalYearSkipPreviousYearEncumbrance() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void ledgerTotals() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @Disabled
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopenOrderAfterRolloverMODORDERS542() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unreleaseEncumbrance() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updateEncumbranceTransactions() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void verifyGetFundsWithoutQueryWhereUserHasUnitsAndFilterOnlyByUnits() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void verifyGetFundsWithQueryWhereUserHasUnits() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() {
    runFeatureTest(Feature.FEATURE_35.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void whenCreatingBudgetAddExpenseClassesIfThemProvidedByUser() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }
}
