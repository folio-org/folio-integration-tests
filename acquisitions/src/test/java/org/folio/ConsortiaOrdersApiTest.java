package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "consortia")
class ConsortiaOrdersApiTest extends TestBaseEureka {

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
