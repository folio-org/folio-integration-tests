package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class EdgeRtacTests extends TestBase {

  public EdgeRtacTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:domain/edge-rtac/features/")));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/edge-rtac/rtac-junit.feature");
  }

  @Test
  void rtacTest() {
    runFeatureTest("rtac");
  }
}
