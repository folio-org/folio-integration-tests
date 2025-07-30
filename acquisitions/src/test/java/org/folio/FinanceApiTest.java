package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-finance")
public class FinanceApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-finance/features/";

  public FinanceApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
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
  void allowableEncumbranceAndExpenditureRestrictions() {
    runFeatureTest("allowable-encumbrance-and-expenditure-restrictions");
  }

  @Test
  void batchTransactionApi() {
    runFeatureTest("batch-transaction-api");
  }

  @Test
  void budgetAndFundOptimisticLocking() {
    runFeatureTest("budget-and-fund-optimistic-locking");
  }

  @Test
  void budgetCanBeDeleteIfHaveOnlyAllocationTransactionsFromOrTo() {
    runFeatureTest("budget-can-be-deleted-if-have-only-allocation-transactions-from-or-to");
  }

  @Test
  void budgetCanNotBeDeletedIfHaveOtherThanAllocationTransactions() {
    runFeatureTest("budget-can-not-be-deleted-if-have-other-than-allocation-transactions");
  }

  @Test
  void budgetCanNotBeDeletedIfHaveToAndFromFundInAllocationTransactions() {
    runFeatureTest("budget-can-not-be-deleted-if-have-to-and-from-fund-in-allocation-transactions");
  }

  @Test
  void budgetExpenseClasses() {
    runFeatureTest("budget-expense-classes");
  }

  @Test
  void shouldVerifyBudgetsTotalsCalculation () {
    runFeatureTest("budgets-totals-calculation");
  }

  @Test
  void budgetTransferTransactions() {
    runFeatureTest("budget-transfer-transactions");
  }

  @Test
  void budgetUpdate() {
    runFeatureTest("budget-update");
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesCurrentBudget() {
    runFeatureTest("create-planned-budget-without-expense-classes-and-current-budget");
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesWhenNoCurrentBudget() {
    runFeatureTest("create-planned-budget-without-expense-classes-when-there-is-no-current-budget");
  }

  @Test
  void currentBudgetForFund() {
    runFeatureTest("current-budget-for-fund");
  }

  @Test
  @Disabled
  void returnCurrentFiscalYearConsiderTimeZone() {
    runFeatureTest("curr-fiscal-year-for-ledger-consider-time-zone");
  }

  @Test
  void financeDataTest() {
    runFeatureTest("finance-data");
  }

  @Test
  void fiscalYearTotals() {
    runFeatureTest("fiscal-year-totals");
  }

  @Test
  void groupAndLedgerTransfersAfterRollover() {
    runFeatureTest("group-and-ledger-transfers-after-rollover");
  }

  @Test
  void groupExpenseClasses() {
    runFeatureTest("group-expense-classes");
  }

  @Test
  void groupFiscalYearTotals() {
    runFeatureTest("group-fiscal-year-totals");
  }

  @Test
  void ledgerPreviewRollover() {
    runFeatureTest("ledger-fiscal-year-preview-rollover");
  }

  @Test
  void ledgerPreviewRolloverNeedCloseBudgets() {
    runFeatureTest("ledger-fiscal-year-preview-rollover-need-close-budgets");
  }

  @Test
  void ledgerFiscalYearRolloverFailResistanceWhenDuplicateEncumbrance() {
    runFeatureTest("ledger-fiscal-year-rollover-fail-resistance-when-duplicate-encumbrance");
  }

  @Test
  void testLedgerFiscalYearRollover_MODFISTO_247() {
    runFeatureTest("ledger-fiscal-year-rollover-MODFISTO-247");
  }

  @Test
  void ledgerFiscalYearRolloverOrderWithBrokenEncumbrance() {
    runFeatureTest("ledger-fiscal-year-rollover-order-with-broken-encumbrance");
  }

  @Test
  void ledgerFiscalYearRolloverPolAndSystemCurrenciesAreDifferent() {
    runFeatureTest("ledger-fiscal-year-rollover-pol-and-system-currencies-are-different");
  }

  @Test
  void shouldVerifyLedgerFiscalYearRolloversMultiple () {
    runFeatureTest("ledger-fiscal-year-rollovers-multiple");
  }

  @Test
  void ledgerFiscalYearRolloversSequential() {
    runFeatureTest("ledger-fiscal-year-sequential-rollovers");
  }

  @Test
  void ledgerFiscalYearRolloversSequentialSkipPreviousYearEncumbrance() {
    runFeatureTest("ledger-fiscal-year-skip-previous-year-encumbrance");
  }

  @Test
  void ledgerTotals() {
    runFeatureTest("ledger-totals");
  }

  @Test
  void unopenOrderAfterRolloverMODORDERS_542 () {
    runFeatureTest("unopen-order-after-rollover-MODORDERS-542");
  }

  @Test
  void unreleaseEncumbrance() {
    runFeatureTest("unrelease-encumbrance");
  }

  @Test
  void updateEncumbranceTransactions() {
    runFeatureTest("update-encumbrance-transactions");
  }

  @Test
  void verifyGetFundsWithoutQueryWhereUserHasUnitsFilerOnlyByUnits() {
    runFeatureTest("acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units");
  }

  @Test
  void verifyGetFundsWithQueryWhereUserHasUnits() {
    runFeatureTest("acq-units/verify-get-funds-with-query-where-user-has-units");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() {
    runFeatureTest("when-creating-budget-add-expense-classes-from-previous-budget-automatically");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesProvidedByUser() {
    runFeatureTest("when-creating-budget-add-expense-classes-if-them-provided-by-user");
  }

}
