package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "consortia")
@Deprecated(forRemoval = true)
@Disabled
class ConsortiaOrdersApiTest extends TestBase {

  // Default module settings :
  private static final String TEST_BASE_PATH = "classpath:thunderjet/consortia/features/";

  public ConsortiaOrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void consortiaOrdersApiTest() {
    runFeature("classpath:thunderjet/consortia/consortia-orders-junit.feature");
  }

}
