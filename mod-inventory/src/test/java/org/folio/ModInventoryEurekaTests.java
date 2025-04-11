package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "folijet", module = "mod-inventory")
public class ModInventoryEurekaTests extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:folijet/mod-inventory/eureka-features/";

  public ModInventoryEurekaTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:folijet/mod-inventory/inventory-junit-eureka.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void mod_inventoryTest() {
    runFeatureTest("inventoryFeatureTest.feature");
  }

  @Test
  void mod_inventory_setForDeletion() {
    runFeatureTest("setForDeletion.feature");
  }
}
