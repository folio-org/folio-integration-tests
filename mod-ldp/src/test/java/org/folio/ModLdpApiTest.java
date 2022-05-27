package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thor", module = "mod-ldp")
public class ModLdpApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:thor/mod-ldp/features/";

  public ModLdpApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:thor/mod-ldp/mod-ldp-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }
  
  @Test
  void databaseConnectionTest() {
    runFeatureTest("databaseConnection.feature");
  }

}
