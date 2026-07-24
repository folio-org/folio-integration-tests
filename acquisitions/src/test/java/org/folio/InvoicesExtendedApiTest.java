package org.folio;

import org.folio.shared.AcquisitionsTest;
import org.folio.shared.SharedInvoicesTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.TestFactory;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import java.util.Arrays;
import java.util.stream.Stream;

import static org.junit.jupiter.api.DynamicTest.dynamicTest;

@Order(12)
@FolioTest(team = "thunderjet", module = "mod-invoice")
public class InvoicesExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-invoice/features/";
  private static final String TEST_TENANT = "testinvoice";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    // moved from InvoicesSmokeApiTest (TestRail group = Extended)
    "pay-invoice-with-0-value",
    "fund-code-auto-populate-invoice-lines"
  };

  public InvoicesExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedInvoicesTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    try {
      SharedInvoicesTenant.cleanupTenant(this.getClass(), this::runFeature);
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
