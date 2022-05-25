package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "mod-patron-blocks")
class ModPatronBlocksTests extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:vega/mod-patron-blocks/features/";

  public ModPatronBlocksTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-patron-blocks/patron-blocks-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
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
    runFeatureTest("automatedPatronBlocks");
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
