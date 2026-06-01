package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "keycloak-upgrade")
class KeycloakUpgradeSeedTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/keycloak-upgrade/features/";

  KeycloakUpgradeSeedTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Override
  public void runHook() {
    KeycloakUpgradeTenantState.prepareSeedTenant();
    super.runHook();
  }

  @Test
  void seedBeforeUpgrade() {
    runFeatureTest("seed-before-upgrade");
  }
}
