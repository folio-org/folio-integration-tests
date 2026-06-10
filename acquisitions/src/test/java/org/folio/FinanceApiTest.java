package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedTenantOptions;
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
import java.util.UUID;
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

@Order(10)
@FolioTest(team = "thunderjet", module = "mod-finance")
public class FinanceApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-finance/features/";
  private static final String TEST_TENANT = "testfinance";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "allowable-encumbrance-and-expenditure-restrictions",
    "batch-transaction-api",
    "budget-and-fund-optimistic-locking",
    "budget-can-be-deleted-if-have-only-allocation-transactions-from-or-to",
    "budget-can-not-be-deleted-if-have-other-than-allocation-transactions",
    "budget-can-not-be-deleted-if-have-to-and-from-fund-in-allocation-transactions",
    "budget-expense-classes",
    "budgets-totals-calculation",
    "budget-transfer-transactions",
    "budget-update",
    "create-planned-budget",
    "current-budget-for-fund",
    /*"curr-fiscal-year-for-ledger-consider-time-zone",*/
    "finance-data",
    "fiscal-year-totals",
    "group-and-ledger-transfers-after-rollover",
    "group-expense-classes",
    "group-fiscal-year-totals",
    "ledger-fiscal-year-preview-rollover",
    "ledger-fiscal-year-preview-rollover-need-close-budgets",
    "ledger-fiscal-year-rollover-fail-resistance-when-duplicate-encumbrance",
    "ledger-fiscal-year-rollover-MODFISTO-247",
    "ledger-fiscal-year-rollover-order-with-broken-encumbrance",
    "ledger-fiscal-year-rollover-pol-and-system-currencies-are-different",
    "ledger-fiscal-year-rollovers-multiple",
    "ledger-fiscal-year-sequential-rollovers",
    "ledger-fiscal-year-skip-previous-year-encumbrance",
    "ledger-totals",
    "unopen-order-after-rollover-MODORDERS-542",
    "unrelease-encumbrance",
    "update-encumbrance-transactions",
    "recalculate-budget",
    "acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units",
    "acq-units/verify-get-funds-with-query-where-user-has-units"
  };

  public FinanceApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", SharedTenantOptions.generateTenantName(TEST_TENANT));
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-finance/init-finance.feature");
  }

  @AfterAll
  @Override
  public void afterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
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
