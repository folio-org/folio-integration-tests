package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedInvoicesTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestFactory;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import java.util.Arrays;
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

@Order(11)
@FolioTest(team = "thunderjet", module = "mod-invoice")
public class InvoicesApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-invoice/features/";
  private static final String TEST_TENANT = "testinvoice";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "approve-and-pay-invoice-with-past-fiscal-year",
    "batch-voucher-export-with-many-lines",
    "batch-voucher-uploaded",
    "cancel-invoice",
    "check-approve-and-pay-invoice-with-odd-pennies-number",
    "check-approve-and-pay-invoice-with-zero-dollar-amount",
    "check-error-respose-with-fundcode-upon-invoice-approval",
    "check-invoice-and-invoice-lines-deletion-restrictions",
    "check-invoice-full-flow-where-subTotal-is-negative",
    "check-invoice-lines-and-documents-are-deleted-with-invoice",
    "check-invoice-lines-with-vat-adjustments",
    "check-invoice-line-validation-with-adjustments",
    "check-lock-totals-and-calculated-totals-in-invoice-approve-time",
    "check-remaining-amount-upon-invoice-approval",
    "check-that-can-not-approve-invoice-if-organization-is-not-vendor",
    "check-that-changing-protected-fields-forbidden-for-approved-invoice",
    "check-that-not-possible-add-invoice-line-to-approved-invoice",
    "check-that-not-possible-pay-for-invoice-if-no-voucher",
    "check-that-not-possible-pay-for-invoice-without-approved",
    "check-that-voucher-exist-with-parameters",
    "create-voucher-lines-honor-expense-classes",
    "edit-subscription-dates-after-invoice-paid",
    "exchange-rate-update-after-invoice-approval",
    "expense-classes-validation",
    "fiscal-year-balance-with-negative-available",
    "invoice-fiscal-years",
    "invoice-with-identical-adjustments",
    "invoice-with-lock-totals-calculated-totals",
    "prorated-adjustments-special-cases",
    "set-invoice-fiscal-year-automatically",
    "should_populate_vendor_address_on_get_voucher_by_id",
    "voucher-numbers",
    "voucher-with-lines-using-same-external-account",
    "fund-code-auto-populate-invoice-lines",
    "delete-line-check-next-line-number"
  };

  public InvoicesApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedInvoicesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    SharedInvoicesTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @Override
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  public void runFeatures() {
    runFeatures(Arrays.asList(FEATURES), THREAD_COUNT, null);
  }

  @TestFactory
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  @Execution(ExecutionMode.CONCURRENT)
  Stream<DynamicTest> runFeaturesSeparately() {
    return Stream.of(FEATURES).map(featureName -> dynamicTest(featureName, () -> runFeatureTest(featureName)));
  }
}
