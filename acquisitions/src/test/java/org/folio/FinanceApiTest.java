package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class FinanceApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-finance/features/";
  private static final String TEST_SUITE_NAME = "mod-finance";
  private static final long TEST_SECTION_ID = 3347L;
  // TODO: make TEST_SUITE_ID different for each module
  private static final long TEST_SUITE_ID = 161L;

  public FinanceApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
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

  @BeforeAll
  public void financeApiTestBeforeAll() {
    runFeature("classpath:domain/mod-finance/finance-junit.feature");
  }

  @AfterAll
  public void financeApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
