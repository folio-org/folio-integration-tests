package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedOrdersTenant;
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

@Order(3)
@FolioTest(team = "thunderjet", module = "mod-orders")
class OrdersApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    // SLOW FEATURES - moved to the top so that a complete execution with threads finishes earlier
    "open-order-instance-link",
    "order-status-automatic-change",
    // END OF SLOW FEATURES
    "bind-piece",
    "cancel-and-delete-order",
    "cancel-item-after-canceling-poline-in-multi-line-orders",
    "cancel-order",
    "change-location-when-receiving-piece",
    "change-pending-distribution-with-inactive-budget",
    "check-estimated-price-with-composite-order",
    "check-holding-instance-creation-with-createInventory-options",
    "check-new-tags-in-central-tag-repository",
    /*"check-order-lines-number-retrieve-limit",*/
    "check-re-encumber-property",
    "close-order-and-release-encumbrances",
    "close-order-including-lines",
    "create-five-pieces",
    "create-open-composite-order",
    "create-order-that-has-not-enough-money",
    "delete-fund-distribution",
    "delete-opened-order-and-lines",
    "encumbrance-released-when-order-closes",
    "encumbrance-tags-inheritance",
    "encumbrance-update-after-expense-class-change",
    "expense-class-handling-for-order-and-lines",
    "find-holdings-by-location-and-instance-for-mixed-pol",
    "fund-codes-in-open-order-error",
    "increase-poline-quantity-for-open-order",
    "independent-acquisitions-unit-for-ordering-and-receiving",
    "item-and-holding-operations-for-order-flows",
    "MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false",
    "MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true",
    "MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false",
    "MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package",
    "MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item",
    "move-item-and-holding-to-update-order-data",
    "open-and-unopen-order",
    "open-ongoing-order",
    "open-ongoing-order-if-interval-or-renewaldate-notset",
    "open-order-failure-side-effects",
    "open-order-success-with-expenditure-restrictions",
    "open-orders-with-poLines",
    "open-order-with-different-po-line-currency",
    "open-order-with-manual-exchange-rate",
    "open-order-with-many-product-ids",
    "open-order-without-holdings",
    "open-order-with-restricted-locations",
    "open-order-with-the-same-fund-distributions",
    "order-event",
    "order-line-event",
    "parallel-create-piece",
    "parallel-update-order-lines-different-orders",
    "parallel-update-order-lines-same-order",
    "pe-mix-update-piece",
    "piece-audit-history",
    "piece-batch-job",
    "piece-deletion-restriction",
    /*"piece-operations-for-order-flows-mixed-order-line",*/
    "pieces-batch-update-status",
    "piece-status-transitions",
    "poline_change_instance_connection",
    "poline-change-instance-connection-with-holdings-items",
    "poline-claiming-interval-checks",
    "productIds-field-error-when-attempting-to-update-unmodified-order",
    "receive-20-pieces",
    "receive-piece-against-non-package-pol",
    "receive-piece-against-package-pol",
    "reopen-order-creates-encumbrances",
    "reopen-order-with-50-lines",
    "retrieve-titles-with-honor-of-acq-units",
    "routing-list-print-template",
    "routing-lists-api",
    "should-decrease-quantity-when-delete-piece-with-no-location",
    "three-fund-distributions",
    "title-instance-creation",
    "unlink-title",
    "unopen-order-with-different-fund",
    "unreceive-piece-and-check-order-line",
    "update_fields_in_item",
    "update-purchase-order-with-order-lines",
    "update-purchase-order-workflow-status",
    "validate-fund-distribution-for-zero-price",
    "validate-pol-receipt-not-required-with-checkin-items",
    "create-order-with-suppress-instance-from-discovery",
    "auto-populate-fund-code",
    "holding-detail",
    "piece-item-synchronization",
    "open-order-with-invalid-material-type-rollback",
    "no-side-effect-with-failed-piece-operation",
    "batch-create-pieces-updates-encumbrance"
  };

  public OrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedOrdersTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    SharedOrdersTenant.cleanupTenant(this.getClass(), this::runFeature);
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
