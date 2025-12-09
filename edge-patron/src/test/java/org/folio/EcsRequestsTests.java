package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "edge-patron")
class EcsRequestsTests extends TestBaseEureka {

  public EcsRequestsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:consortia/features/")));
  }

  @Test
  void ecsRequestsTest() {
    runFeatureTest("ecs-requests.feature");
  }
}
