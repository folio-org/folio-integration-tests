package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;
import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.Ignore;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InvoicesApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-invoice";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1387l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-invoice/features/";

  private static String TEST_CASE_NAME_1 = "check-invoice-and-invoice-lines-deletion-restrictions";
  private static String TEST_CASE_NAME_2 = "check-remaining-amount-upon-invoice-approval";
  private static String TEST_CASE_NAME_3 = "create-voucher-lines-honor-expense-classes";
  private static String TEST_CASE_NAME_4 = "exchange-rate-update-after-invoice-approval";
  private static String TEST_CASE_NAME_5 = "prorated-adjustments-special-cases";

  public InvoicesApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Ignore
  @Karate.Test
  Karate invoiceTest() {
    runHook();
    return Karate.run("classpath:domain/mod-invoice/invoice.feature");
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() throws IOException {
    commonTestCase(TEST_CASE_NAME_1);
  }

  @Test
  void checkRemainingAmountInvoiceApproval() throws IOException {
    commonTestCase(TEST_CASE_NAME_2);
  }

  @Test
  void createVoucherLinesExpenseClasses() throws IOException {
    commonTestCase(TEST_CASE_NAME_3);
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() throws IOException {
    commonTestCase(TEST_CASE_NAME_4);
  }

  @Test
  void proratedAdjustmentsSpecialCases() throws IOException {
    commonTestCase(TEST_CASE_NAME_5);
  }

  @BeforeAll
  public static void invoicesApiTestBeforeAll() {
    Karate.run("classpath:domain/mod-invoice/invoice.feature");
  }

  @AfterAll
  public static void invoicesApiTestAfterAll() {
    Karate.run("classpath:common/destroy-data.feature");
  }

}