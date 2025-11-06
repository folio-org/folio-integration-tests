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
import org.junit.jupiter.api.DisplayName;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesCriticalPathApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";

  public CrossModulesCriticalPathApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void crossModulesCriticalPathApiTestBeforeAll() {
    System.setProperty("testTenant", "testcross" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/cross-modules/init-cross-modules.feature");
  }

  @AfterAll
  public void crossModulesCriticalPathApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) (C356782, C356412, C358532, C356785) Unrelease Encumbrances When Reopen Ongoing Order With Related Paid Invoice And Receiving")
  void unreleaseEncumbrancesWhenReopenOngoingOrderWithRelatedPaidInvoiceAndReceiving() {
    runFeatureTest("unrelease-encumbrances-when-reopen-ongoing-order-with-related-paid-invoice-and-receiving");
  }

  @Test
  @DisplayName("(Thunderjet) (C844257) Encumbrance Calculated Correctly For A Un-Opened Ongoing Order With An Approved Invoice And After Canceling An Approved Invoice Release Encumbrance True")
  void encumbranceCalculatedCorrectlyForUnopenedOngoingOrderWithApprovedInvoice() {
    runFeatureTest("encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C825437) Encumbrance Remains 0 For A 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Paid Invoice Release Encumbrance True")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoice() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C829881) Encumbrance Remains 0 For A Re-Opened 0 Dollar Ongoing Order With A Paid Invoice Unreleasing Encumbrance And Canceling A Paid Invoice Release Encumbrance True")
  void encumbranceRemains0ForReOpened0DollarOngoingOrderWithPaidInvoice() {
    runFeatureTest("encumbrance-remains-0-for-re-opened-0-dollar-ongoing-order-with-paid-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C852110) Encumbrance Remains The Same After Cancelling A Credited Paid Invoice Release Encumbrance False")
  void encumbranceRemainsSameAfterCancellingCreditedInvoice() {
    runFeatureTest("encumbrance-remains-same-after-cancelling-credited-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C844264) Encumbrance Remains 0 For An 0 Dollar Ongoing Order When Paid And Credited Invoices Exist And After Invoices Cancelation Release Encumbrance False")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidAndCreditedInvoices() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-and-credited-invoices");
  }

  @Test
  @DisplayName("(Thunderjet) (C844254) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Invoice Unreleasing Encumbrance And Canceling Another Credited Invoice Release Encumbrance True")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoiceUnreleasingAndCancelingCreditedInvoice() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-and-canceling-credited-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C844262) Encumbrance Remains 0 For A Re-Opened One-Time Order With An Approved Invoice Unreleasing Encumbrance And Canceling An Invoice Release Encumbrance True")
  void encumbranceRemains0ForReopenedOneTimeOrderWithApprovedInvoiceUnreleasingAndCancelingInvoice() {
    runFeatureTest("encumbrance-remains-0-for-reopened-one-time-order-with-approved-invoice-unreleasing-and-canceling-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C400618) Initial Encumbrance Amount Remains The Same As It Was Before Payment After Cancelling Related Paid Credit Invoice Another Related Paid Invoice Exists")
  void encumbranceRemainsSameAfterCancellingCreditInvoiceWithAnotherPaidInvoice() {
    runFeatureTest("encumbrance-remains-same-after-cancelling-credit-invoice-with-another-paid-invoice");
  }

  @Test
  @DisplayName("(Thunderjet) (C864744) Encumbrance Remains 0 For An 0 Dollar Ongoing Order After Canceling A Paid Credit Invoice And Canceling Another Paid Invoice Release Encumbrance True")
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingCreditAndPaidInvoicesReleaseTrue() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-credit-and-paid-invoices-release-true");
  }

  @Test
  @DisplayName("(Thunderjet) (C870004) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  void encumbranceUpdatesCorrectlyAfterCancelingFirstOfTwoPaidInvoices() {
    runFeatureTest("encumbrance-updates-correctly-after-canceling-first-of-two-paid-invoices");
  }

  @Test
  @DisplayName("(Thunderjet) (C877072) Encumbrance Is Unreleased After Cancelling The Related Paid Invoice And Re-Opening The Order Release Encumbrance False")
  void encumbranceUnreleasedAfterCancellingInvoiceAndReopeningOrder() {
    runFeatureTest("encumbrance-unreleased-after-cancelling-invoice-and-reopening-order");
  }

  @Test
  @DisplayName("(Thunderjet) (C877073) Encumbrance Is Calculated Correctly After Canceling A Paid Invoice When Other Paid And Credit Invoices Exist Release Encumbrance False")
  void encumbranceCalculatedCorrectlyAfterCancelingInvoiceWithOtherPaidAndCreditInvoices() {
    runFeatureTest("encumbrance-calculated-correctly-after-canceling-invoice-with-other-paid-and-credit-invoices");
  }

  @Test
  @DisplayName("(Thunderjet) (C889715) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice When Other Approved And Credit Invoices Exist Release Encumbrance False")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceWithOtherInvoicesReleaseFalse() {
    runFeatureTest("encumbrance-calculated-correctly-after-canceling-approved-invoice-with-other-invoices-release-false");
  }

  @Test
  @DisplayName("(Thunderjet) (C889716) Encumbrance Is Unreleased After Cancelling The Related Approved Invoice And Re-Opening The Order Release Encumbrance False")
  void encumbranceUnreleasedAfterCancellingApprovedInvoiceAndReOpeningOrderReleaseFalse() {
    runFeatureTest("encumbrance-unreleased-after-cancelling-approved-invoice-and-re-opening-order-release-false");
  }

  @Test
  @DisplayName("(Thunderjet) (C889714) Encumbrance Is Calculated Correctly After Canceling An Approved Invoice With Amount Exceeding The Initial Encumbrance Release Encumbrance False")
  void encumbranceCalculatedCorrectlyAfterCancelingApprovedInvoiceExceedingInitialEncumbranceReleaseFalse() {
    runFeatureTest("encumbrance-calculated-correctly-after-canceling-approved-invoice-exceeding-initial-encumbrance-release-false");
  }

  @Test
  @DisplayName("(Thunderjet) (C889713) Encumbrance Remains The Same After Cancelling A Credited Approved Invoice Release Encumbrance False")
  void encumbranceRemainsSameAfterCancellingCreditedApprovedInvoiceReleaseFalse() {
    runFeatureTest("encumbrance-remains-same-after-cancelling-credited-approved-invoice-release-false");
  }

  @Test
  @Disabled
  @DisplayName("(Thunderjet) Scenario 5 - mod-orders becomes unavailable after removing Fund distribution from POL")
  void encumbranceAfterRemovingFundDistributionFromPol() {
    runFeatureTest("encumbrance-after-removing-fund-distribution-from-pol");
  }

  @Test
  @DisplayName("(Thunderjet) (C877086) Encumbrance Is Created As Released After Releasing It Manually And Changing The Fund Distribution")
  void encumbranceReleasedAfterManualReleaseAndFundChangeOngoing() {
    runFeatureTest("encumbrance-released-after-manual-release-and-fund-change-ongoing");
  }

  @Test
  @DisplayName("(Thunderjet) (C877085) Encumbrance Is Created As Released After Changing The Fund Distribution With Paid Invoice Release Encumbrance True")
  void encumbranceReleasedAfterFundChangeWithPaidInvoiceReleaseTrue() {
    runFeatureTest("encumbrance-released-after-fund-change-with-paid-invoice-release-true");
  }

  @Test
  @DisplayName("(Thunderjet) (C877084) Encumbrance Is Created As Released After Manual Release And Fund Change With Paid Invoice Release Encumbrance False")
  void encumbranceReleasedAfterManualReleaseAndFundChangeWithPaidInvoiceReleaseFalse() {
    runFeatureTest("encumbrance-released-after-manual-release-and-fund-change-with-paid-invoice-release-false");
  }
    
  @DisplayName("(Thunderjet) (C357580) Budget Summary And Encumbrances Updated Correctly When Editing POL With Related Invoice After Rollover Of Fiscal Year")
  void budgetAndEncumbranceUpdatedCorrectlyAfterEditingPolWithInvoiceAfterRollover() {
    runFeatureTest("budget-and-encumbrance-updated-correctly-after-editing-pol-with-invoice-after-rollover");
  }
  
  @Test
  @DisplayName("(Thunderjet) (C895660) Cancel A Paid Invoice After Changing Fund Distribution In The PO Line")
  void cancelPaidInvoiceAfterChangingFundDistribution() {
    runFeatureTest("cancel-paid-invoice-after-changing-fund-distribution");
  }
}
