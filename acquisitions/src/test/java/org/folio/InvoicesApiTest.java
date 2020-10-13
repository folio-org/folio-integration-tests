package org.folio;

import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InvoicesApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-invoice";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1387l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-invoice/features/";

  public InvoicesApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() throws IOException {
    runFeatureTest("check-invoice-and-invoice-lines-deletion-restrictions");
  }

  @Test
  void checkRemainingAmountInvoiceApproval() throws IOException {
    runFeatureTest("check-remaining-amount-upon-invoice-approval");
  }

  @Test
  void createVoucherLinesExpenseClasses() throws IOException {
    runFeatureTest("create-voucher-lines-honor-expense-classes");
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() throws IOException {
    runFeatureTest("exchange-rate-update-after-invoice-approval");
  }

  @Test
  void proratedAdjustmentsSpecialCases() throws IOException {
    runFeatureTest("prorated-adjustments-special-cases");
  }

  @BeforeAll
  public static void invoicesApiTestBeforeAll() {
    runFeature("classpath:domain/mod-invoice/invoice-junit.feature");
  }

  @AfterAll
  public static void invoicesApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}