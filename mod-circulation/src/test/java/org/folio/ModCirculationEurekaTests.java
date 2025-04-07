package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@Disabled
@FolioTest(team = "vega", module = "mod-circulation")
class ModCirculationEurekaTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:vega/mod-circulation/features/";

  public ModCirculationEurekaTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-circulation/circulation-junit-eureka.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void rootTest() {
    runFeatureTest("root");
  }

  @Test
  void runParallelTest() {
    runFeatureTest("parallel-checkout", 3);
  }

}