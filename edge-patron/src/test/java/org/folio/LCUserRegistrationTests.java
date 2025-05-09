package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "edge-patron")
@Disabled("Migrated to Eureka")
class LCUserRegistrationTests extends TestBase {

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
    runFeature("classpath:common/destroy-data.feature");
  }
}
