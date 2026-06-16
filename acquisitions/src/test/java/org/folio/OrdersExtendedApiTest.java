package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedOrdersTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
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

@Order(4)
@FolioTest(team = "thunderjet", module = "mod-orders")
class OrdersExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "piece-status-transitions-claiming",
    "add-piece-to-cancelled-order",
    "update-po-lines-when-order-cancelled",
    // moved from OrdersSmokeApiTest (TestRail group = Extended)
    "create-order-payment-not-required-fully-receive",
    "create-order-check-items",
    "delete-one-piece-in-receiving",
    "change-order-instance-connection",
    // moved from OrdersCriticalPathApiTest (TestRail group = Extended)
    "unopen-order-delete-empty-holding-two-locs",
    "unopen-order-delete-empty-holding-two-pols",
    "unopen-order-delete-empty-holding-mixed-pols",
    "pe-mix-change-instance-connection-create-new-delete-holdings",
    "pe-mix-synchronized-change-instance-connection-create-new-delete-holdings",
    "pe-mix-synchronized-change-instance-connection-find-create-delete-holdings",
    "pe-mix-change-instance-connection-find-create-keep-holdings",
    "physical-change-instance-connection-find-create-delete-holdings",
    "pe-mix-change-instance-connection-create-new-keep-holdings",
    "pe-mix-synchronized-change-instance-connection-create-new-keep-holdings",
    "change-piece-status-unreceivable-to-expected-ongoing-order",
    "item-under-holdings-after-instance-connection-change-find-or-create",
    "item-under-holdings-after-instance-connection-change-move",
    "item-under-holdings-after-instance-connection-change-create-new",
    "pe-mix-change-instance-connection-find-create-delete-holdings",
    "unopen-open-order-with-pol-and-fund-distribution",
    "open-order-with-resolution-statuses",
    "encumbrance-expense-class-switch-two-distributions"
};

  public OrdersExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedOrdersTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    try {
      SharedOrdersTenant.cleanupTenant(this.getClass(), this::runFeature);
    } finally {
      super.afterAll();
    }
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
