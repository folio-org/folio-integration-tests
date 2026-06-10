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

@Order(16)
@FolioTest(team = "thunderjet", module = "mod-gobi")
class GobiApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";
  private static final String TEST_TENANT = "testmodgobi";
  private static final int THREAD_COUNT = 1; // Gobi tests share tenant resources, must run sequentially

  private static final String[] FEATURES = {
    "gobi-api-tests",
    "find-holdings-by-location-and-instance",
    "validate-pol-receipt-not-required-with-checkin-items",
    "validate-pol-suppress-instance-from-discovery",
    "verify-tenant-address-lookup.feature"
  };

  public GobiApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", SharedTenantOptions.generateTenantName(TEST_TENANT));
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-gobi/init-gobi.feature");
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
