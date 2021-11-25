package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

public class FinanceApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-finance/features/";

  public FinanceApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void budgetExpenseClasses() {
    runFeatureTest("budget-expense-classes");
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
  void allowableEncumbranceAndExpenditureRestrictions() {
    runFeatureTest("allowable-encumbrance-and-expenditure-restrictions");
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
  void groupExpenseClasses() {
    runFeatureTest("group-expense-classes");
  }

  @Test
  void ledgerTotals() {
    runFeatureTest("ledger-totals");
  }

  @Test
  void fiscalYearTotals() {
    runFeatureTest("fiscal-year-totals");
  }

  @Test
  void groupFiscalYearTotals() {
    runFeatureTest("group-fiscal-year-totals");
  }

  @Test
  void transactionSummariesCrud() {
    runFeatureTest("transaction-summaries-crud");
  }

  @Test
  void unreleaseEncumbrance() {
    runFeatureTest("unrelease-encumbrance.feature");
  }

  @Test
  void updateEncumbranceTransactions() {
    runFeatureTest("update-encumbrance-transactions");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() {
    runFeatureTest("when-creating-budget-add-expense-classes-from-previous-budget-automatically");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesProvidedByUser() {
    runFeatureTest("when-creating-budget-add-expense-classes-if-them-provided-by-user");
  }

  @Test
  void ledgerRollover() {
    runFeatureTest("ledger-fiscal-year-rollover");
  }

  @Test
  void ledgerFiscalYearRolloverPolAndSystemCurrenciesAreDifferent() {
    runFeatureTest("ledger-fiscal-year-rollover-pol-and-system-currencies-are-different");
  }

  @Test
  void verifyGetFundsWithQueryWhereUserHasUnits() {
    runFeatureTest("acq-units/verify-get-funds-with-query-where-user-has-units");
  }

  @Test
  void verifyGetFundsWithoutQueryWhereUserHasUnitsFilerOnlyByUnits() {
    runFeatureTest("acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units");
  }


  @Test
  void budgetCanBeDeleteIfHaveOnlyAllocationTransactionsFromOrTo() {
    runFeatureTest("budget-can-be-deleted-if-have-only-allocation-transactions-From-or-To");
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
  void testLedgerFiscalYearRollover_MODFISTO_247() {
    runFeatureTest("ledger-fiscal-year-rollover-MODFISTO-247");
  }

  @Test
  @Disabled
  void returnCurrentFiscalYearConsiderTimeZone() {
    runFeatureTest("curr-fiscal-year-for-ledger-consider-time-zone");
  }

  @Test
  void undefinedTests() {
    runFeatureTest("undefined");
  }

  @Test
  void unopenOrderAfterRolloverMODORDERS_542 () {
    runFeatureTest("unopen-order-after-rollover-MODORDERS-542");
  }

  @BeforeAll
  public void financeApiTestBeforeAll() {
    runFeature("classpath:thunderjet/mod-finance/finance-junit.feature");
  }

  @AfterAll
  public void financeApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
