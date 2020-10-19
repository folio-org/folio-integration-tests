package org.folio;

import static org.folio.testrail.config.TestConfigurationEnum.INVOICES_CONFIGURATION;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.TestRailIntegrationHelper;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InvoicesApiTest extends AbstractTestRailIntegrationTest {

  public InvoicesApiTest() {
    super(new TestRailIntegrationHelper(INVOICES_CONFIGURATION));
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() {
    runFeatureTest("check-invoice-and-invoice-lines-deletion-restrictions");
  }

  @Test
  void checkRemainingAmountInvoiceApproval() {
    runFeatureTest("check-remaining-amount-upon-invoice-approval");
  }

  @Test
  void createVoucherLinesExpenseClasses() {
    runFeatureTest("create-voucher-lines-honor-expense-classes");
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() {
    runFeatureTest("exchange-rate-update-after-invoice-approval");
  }

  @Test
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest("prorated-adjustments-special-cases");
  }

  @BeforeAll
  public void invoicesApiTestBeforeAll() {
    runFeature("classpath:domain/mod-invoice/invoice-junit.feature");
  }

  @AfterAll
  public void invoicesApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}