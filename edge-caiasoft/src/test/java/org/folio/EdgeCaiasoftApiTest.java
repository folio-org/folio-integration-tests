package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EdgeCaiasoftApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/edge-caiasoft/features/";

  public EdgeCaiasoftApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void testAccessionIfItemWithinHoldingWithRemoteLocation() {
    runFeatureTest("item-within-holding-with-remote-location");
  }

  @Test
  void testAccessionIfItemsWithinHoldingHaveRemoteLocation() {
    runFeatureTest("items-within-holding-have-remote-location");
  }
}
