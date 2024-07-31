package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "dreamliner", module = "edge-rtac")
class EdgeRtacTests extends TestBase {

  public EdgeRtacTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:core_platform/edge-rtac/features/")));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:core_platform/edge-rtac/rtac-junit.feature");
  }

  @Test
  void rtacTest() {
    runFeatureTest("rtac");
  }

  @Test
  void rtacFromOrderPieceTest() {
    runFeatureTest("rtac-from-order-piece");
  }
}
