package org.folio;

import com.intuit.karate.junit5.Karate;
import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class FinanceApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-finance";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1386l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-finance/features/";

  public FinanceApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

//  @Ignore
//  @Karate.Test
//  Karate financeTest() {
//    runHook();
//    return Karate.run("classpath:domain/mod-finance/finance.feature");
//  }

  @Test
  void budgetExpenseClasses() throws IOException {
    runFeatureTest("budget-expense-classes");
  }

  @Test
  void budgetTransferTransactions() throws IOException {
    runFeatureTest("budget-transfer-transactions");
  }

  @Test
  void budgetUpdate() throws IOException {
    runFeatureTest("budget-update");
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesCurrentBudget() throws IOException {
    runFeatureTest("create-planned-budget-without-expense-classes-and-current-budget");
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesWhenNoCurrentBudget() throws IOException {
    runFeatureTest("create-planned-budget-without-expense-classes-when-there-is-no-current-budget");
  }

  @Test
  void currentBudgetForFund() throws IOException {
    runFeatureTest("current-budget-for-fund");
  }

  @Test
  void groupExpenseClasses() throws IOException {
    runFeatureTest("group-expense-classes");
  }

  @Test
  void ledgerTotals() throws IOException {
    runFeatureTest("ledger-totals");
  }

  @Test
  void transactionSummariesCrud() throws IOException {
    runFeatureTest("transaction-summaries-crud");
  }

  @Test
  void updateEncumbranceTransactions() throws IOException {
    runFeatureTest("update-encumbrance-transactions");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() throws IOException {
    runFeatureTest("when-creating-budget-add-expense-classes-from-previous-budget-automatically");
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesProvidedByUser() throws IOException {
    runFeatureTest("when-creating-budget-add-expense-classes-if-them-provided-by-user");
  }

  @BeforeAll
  public static void financeApiTestBeforeAll() {
    runFeature("classpath:domain/mod-finance/finance-junit.feature");
  }

  @AfterAll
  public static void financeApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}