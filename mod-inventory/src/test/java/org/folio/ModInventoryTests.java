package org.folio;

import net.minidev.json.JSONUtil;
import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ModInventoryTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-inventory/features/";

  public ModInventoryTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/mod-inventory/inventory-junit.feature");
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
