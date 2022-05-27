package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "core-platform", module = "mod-login-saml")
public class ModLoginSamlTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:core_platform/mod-login-saml/";

  public ModLoginSamlTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeatureTest("login-saml-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void orchestrate() {
    runFeatureTest("features/orchestrate.feature");
  }
}
