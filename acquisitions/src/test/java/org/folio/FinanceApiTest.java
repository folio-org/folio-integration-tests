package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;
import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.Ignore;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class FinanceApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-finance";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1386l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-finance/features/";

  private static String TEST_CASE_NAME_1 = "budget-expense-classes";
  private static String TEST_CASE_NAME_2 = "budget-transfer-transactions";
  private static String TEST_CASE_NAME_3 = "budget-update";
  private static String TEST_CASE_NAME_4 = "create-planned-budget-without-expense-classes-and-current-budget";
  private static String TEST_CASE_NAME_5 = "create-planned-budget-without-expense-classes-when-there-is-no-current-budget";
  private static String TEST_CASE_NAME_6 = "current-budget-for-fund";
  private static String TEST_CASE_NAME_7 = "group-expense-classes";
  private static String TEST_CASE_NAME_8 = "ledger-totals";
  private static String TEST_CASE_NAME_9 = "transaction-summaries-crud";
  private static String TEST_CASE_NAME_10 = "update-encumbrance-transactions";
  private static String TEST_CASE_NAME_11 = "when-creating-budget-add-expense-classes-from-previous-budget-automatically";
  private static String TEST_CASE_NAME_12 = "when-creating-budget-add-expense-classes-if-them-provided-by-user";

  public FinanceApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Ignore
  @Karate.Test
  Karate financeTest() {
    runHook();
    return Karate.run("classpath:domain/mod-finance/finance.feature");
  }

  @Test
  void budgetExpenseClasses() throws IOException {
    commonTestCase(TEST_CASE_NAME_1);
  }

  @Test
  void budgetTransferTransactions() throws IOException {
    commonTestCase(TEST_CASE_NAME_2);
  }

  @Test
  void budgetUpdate() throws IOException {
    commonTestCase(TEST_CASE_NAME_3);
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesCurrentBudget() throws IOException {
    commonTestCase(TEST_CASE_NAME_4);
  }

  @Test
  void createPlannedBudgetWithoutExpenseClassesWhenNoCurrentBudget() throws IOException {
    commonTestCase(TEST_CASE_NAME_5);
  }

  @Test
  void currentBudgetForFund() throws IOException {
    commonTestCase(TEST_CASE_NAME_6);
  }

  @Test
  void groupExpenseClasses() throws IOException {
    commonTestCase(TEST_CASE_NAME_7);
  }

  @Test
  void ledgerTotals() throws IOException {
    commonTestCase(TEST_CASE_NAME_8);
  }

  @Test
  void transactionSummariesCrud() throws IOException {
    commonTestCase(TEST_CASE_NAME_9);
  }

  @Test
  void updateEncumbranceTransactions() throws IOException {
    commonTestCase(TEST_CASE_NAME_10);
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesFromPreviousBudgetAutomatically() throws IOException {
    commonTestCase(TEST_CASE_NAME_11);
  }

  @Test
  void whenCreatingBudgetAddExpenseClassesProvidedByUser() throws IOException {
    commonTestCase(TEST_CASE_NAME_12);
  }

  @BeforeAll
  public static void financeApiTestBeforeAll() {
    Karate.run("classpath:domain/mod-finance/finance.feature");
  }

  @AfterAll
  public static void financeApiTestAfterAll() {
    Karate.run("classpath:common/destroy-data.feature");
  }

}