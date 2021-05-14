package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

class OwnersApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-feesfines/features/";

  public OwnersApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void owners() {
    runFeatureTest("owners.feature");
  }
}
