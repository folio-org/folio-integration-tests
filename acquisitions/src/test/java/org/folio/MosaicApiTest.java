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

@Order(15)
@FolioTest(team = "thunderjet", module = "mod-mosaic")
class MosaicApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-mosaic/features/";
  private static final String TEST_TENANT = "testmosaic";
  private static final int THREAD_COUNT = 4;

  private static final String[] FEATURES = {
    "create-order-1-from-minimal-template",
    "create-order-2-from-default-template",
    "create-order-3-from-physical-template",
    "create-order-4-from-electronic-template",
    "create-order-5-from-pe-mix-template",
    "create-order-6-with-open-workflow-status",
    "create-order-7-with-check-in-items",
    "validate-order",
    "generate-default-order-template",
    "create-order-8-with-ongoing-type"
};

  MosaicApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    System.setProperty("testTenant", SharedTenantOptions.generateTenantName(TEST_TENANT));
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-mosaic/init-mosaic.feature");
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
