package org.folio;

import static org.folio.testrail.TestConfigurationEnum.FINANCE_CONFIGURATION;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.TestRailIntegrationHelper;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class FinanceApiTest extends AbstractTestRailIntegrationTest {

  public FinanceApiTest() {
    super(new TestRailIntegrationHelper(FINANCE_CONFIGURATION));
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

  @BeforeAll
  public void financeApiTestBeforeAll() {
    runFeature("classpath:domain/mod-finance/finance-junit.feature");
  }

  @AfterAll
  public void financeApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}