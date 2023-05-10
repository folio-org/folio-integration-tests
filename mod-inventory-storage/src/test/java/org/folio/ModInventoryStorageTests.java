package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "mod-inventory-storage")
public class ModInventoryStorageTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:prokopovych/mod-inventory-storage/features/";

  public ModInventoryStorageTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:spitfire/mod-inventory-storage/inventory-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void mod_inventoryTest() {
    runFeatureTest("inventoryFeatureTest");
  }
}
