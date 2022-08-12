package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@Disabled
@FolioTest(team = "prokopovych", module = "edge-rtac")
class EdgeRtacTests extends TestBase {

  public EdgeRtacTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:prokopovych/edge-rtac/features/")));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:prokopovych/edge-rtac/rtac-junit.feature");
  }

  @Test
  void rtacTest() {
    runFeatureTest("rtac");
  }
}
