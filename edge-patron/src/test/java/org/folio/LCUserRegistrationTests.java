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
@FolioTest(team = "vega", module = "edge-patron")
class LCUserRegistrationTests extends TestBaseEureka {

  public LCUserRegistrationTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:vega/edge-patron/features/")));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/edge-patron/patron-junit.feature");
  }

  @Test
  void patronTest() {
    runFeatureTest("lc-user-registration");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }
}
