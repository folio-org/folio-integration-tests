package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

class LimitsApiTest extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/mod-patron-blocks/features/";

  public LimitsApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void limitsTest() {
    runFeatureTest("limits");
  }
}
