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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-finance")
public class FinanceApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-finance/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("allowable-encumbrance-and-expenditure-restrictions"),
    FEATURE_2("batch-transaction-api"),
    FEATURE_3("budget-and-fund-optimistic-locking"),
    FEATURE_4("budget-can-be-deleted-if-have-only-allocation-transactions-from-or-to"),
    FEATURE_5("budget-can-not-be-deleted-if-have-other-than-allocation-transactions"),
    FEATURE_6("budget-can-not-be-deleted-if-have-to-and-from-fund-in-allocation-transactions"),
    FEATURE_7("budget-expense-classes"),
    FEATURE_8("budgets-totals-calculation"),
    FEATURE_9("budget-transfer-transactions"),
    FEATURE_10("budget-update"),
    FEATURE_11("create-planned-budget-without-expense-classes-and-current-budget"),
    FEATURE_12("create-planned-budget-without-expense-classes-when-there-is-no-current-budget"),
    FEATURE_13("current-budget-for-fund"),
    FEATURE_14("curr-fiscal-year-for-ledger-consider-time-zone"),
    FEATURE_15("finance-data"),
    FEATURE_16("fiscal-year-totals"),
    FEATURE_17("group-and-ledger-transfers-after-rollover"),
    FEATURE_18("group-expense-classes"),
    FEATURE_19("group-fiscal-year-totals"),
    FEATURE_20("ledger-fiscal-year-preview-rollover"),
    FEATURE_21("ledger-fiscal-year-preview-rollover-need-close-budgets"),
    FEATURE_22("ledger-fiscal-year-rollover-fail-resistance-when-duplicate-encumbrance"),
    FEATURE_23("ledger-fiscal-year-rollover-MODFISTO-247"),
    FEATURE_24("ledger-fiscal-year-rollover-order-with-broken-encumbrance"),
    FEATURE_25("ledger-fiscal-year-rollover-pol-and-system-currencies-are-different"),
    FEATURE_26("ledger-fiscal-year-rollovers-multiple"),
    FEATURE_27("ledger-fiscal-year-sequential-rollovers"),
    FEATURE_28("ledger-fiscal-year-skip-previous-year-encumbrance"),
    FEATURE_29("ledger-totals"),
    FEATURE_30("unopen-order-after-rollover-MODORDERS-542"),
    FEATURE_31("unrelease-encumbrance"),
    FEATURE_32("update-encumbrance-transactions"),
    FEATURE_33("acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units"),
    FEATURE_34("acq-units/verify-get-funds-with-query-where-user-has-units"),
    FEATURE_35("when-creating-budget-add-expense-classes-from-previous-budget-automatically"),
    FEATURE_36("when-creating-budget-add-expense-classes-if-them-provided-by-user");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public FinanceApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void financeApiTestBeforeAll() {
    System.setProperty("testTenant", "testfinance" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-finance/init-finance.feature");
  }

  @AfterAll
  public void financeApiTestAfterAll() {
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
  void allowableEncumbranceAndExpenditureRestrictions() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void batchTransactionApi() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetAndFundOptimisticLocking() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetCanBeDeletedIfHaveOnlyAllocationTransactionsFromOrTo() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetCanNotBeDeletedIfHaveOtherThanAllocationTransactions() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetCanNotBeDeletedIfHaveToAndFromFundInAllocationTransactions() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetExpenseClasses() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetsTotalsCalculation() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetTransferTransactions() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void budgetUpdate() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createPlannedBudgetWithoutExpenseClassesAndCurrentBudget() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createPlannedBudgetWithoutExpenseClassesWhenThereIsNoCurrentBudget() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void currentBudgetForFund() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void currFiscalYearForLedgerConsiderTimeZone() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void financeData() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void fiscalYearTotals() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void groupAndLedgerTransfersAfterRollover() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void groupExpenseClasses() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void groupFiscalYearTotals() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearPreviewRollover() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearPreviewRolloverNeedCloseBudgets() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloverFailResistanceWhenDuplicateEncumbrance() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloverMODFISTO247() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloverOrderWithBrokenEncumbrance() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloverPolAndSystemCurrenciesAreDifferent() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearRolloversMultiple() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearSequentialRollovers() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerFiscalYearSkipPreviousYearEncumbrance() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void ledgerTotals() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @Disabled
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unopenOrderAfterRolloverMODORDERS542() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unreleaseEncumbrance() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateEncumbranceTransactions() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void verifyGetFundsWithoutQueryWhereUserHasUnitsAndFilterOnlyByUnits() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void verifyGetFundsWithQueryWhereUserHasUnits() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() {
    runFeatureTest(Feature.FEATURE_35.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void whenCreatingBudgetAddExpenseClassesIfThemProvidedByUser() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }
}
