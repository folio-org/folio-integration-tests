package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "mod-circulation")
class ModCirculationExtendedTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:vega/mod-circulation/features/";

  public ModCirculationExtendedTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-circulation/circulation-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void rootExtendedTest() {
    runFeatureTest("root-extended");
  }
}
