package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "keycloak-upgrade")
class KeycloakUpgradeVerifyTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/keycloak-upgrade/features/";
  private boolean verified;

  KeycloakUpgradeVerifyTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Override
  public void runHook() {
    KeycloakUpgradeTenantState.prepareVerifyTenant();
    super.runHook();
  }

  @Test
  void verifyAfterUpgrade() {
    runFeatureTest("verify-after-upgrade");
    verified = true;
  }

  @AfterAll
  void tearDown() {
    if (verified) {
      runFeature("classpath:eureka/keycloak-upgrade/features/destroy-upgrade-data.feature");
    }
  }
}
