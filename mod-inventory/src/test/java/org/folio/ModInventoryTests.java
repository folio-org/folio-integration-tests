package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "promin", module = "mod-inventory")
public class ModInventoryTests extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:promin/mod-inventory/features/";

  public ModInventoryTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:promin/mod-inventory/inventory-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void mod_inventoryTest() {
    runFeatureTest("inventoryFeatureTest");
  }

  @Test
  void mod_inventory_setForDeletion() {
    runFeatureTest("setForDeletion.feature");
  }
}
