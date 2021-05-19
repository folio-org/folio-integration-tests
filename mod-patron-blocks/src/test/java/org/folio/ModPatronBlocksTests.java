package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

class ModPatronBlocksTests extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/mod-patron-blocks/features/";

  public ModPatronBlocksTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void limitsTest() {
    runFeatureTest("limits");
  }

  @Test
  void conditionsTest() {
    runFeatureTest("conditions");
  }

  @Test
  void moduleTenantApiTest() {
    runFeatureTest("moduleTenantApi");
  }

  @Test
  void automatedPatronBlockTest() {
    runFeatureTest("automatedPatronBlock");
  }

  @Test
  void eventHandlersTest() {
    runFeatureTest("eventHandlers");
  }

  @Test
  void synchronizationTest() {
    runFeatureTest("synchronization");
  }

  @Test
  void userSummaryTest() {
    runFeatureTest("userSummary");
  }
}
