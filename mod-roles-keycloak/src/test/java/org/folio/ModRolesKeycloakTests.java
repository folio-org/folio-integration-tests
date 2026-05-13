package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "mod-roles-keycloak")
class ModRolesKeycloakTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mod-roles-keycloak/features/";
  private boolean initialized;

  ModRolesKeycloakTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void setup() {
    runFeature("classpath:eureka/mod-roles-keycloak/mod-roles-keycloak-junit.feature");
    initialized = true;
  }

  @AfterAll
  void tearDown() {
    if (initialized) {
      runFeature("classpath:common/eureka/destroy-data.feature");
    }
  }

  @Test
  void capabilities() {
    runFeatureTest("capabilities");
  }

  @Test
  void capabilitySets() {
    runFeatureTest("capability-sets");
  }

  @Test
  void userCapabilities() {
    runFeatureTest("user-capabilities");
  }

  @Test
  void userCapabilitySets() {
    runFeatureTest("user-capability-sets");
  }

  @Test
  void roles() {
    runFeatureTest("roles");
  }

  @Test
  void userRoles() {
    runFeatureTest("user-roles");
  }

  @Test
  void roleCapabilities() {
    runFeatureTest("role-capabilities");
  }

  @Test
  void roleCapabilitySets() {
    runFeatureTest("role-capability-sets");
  }

  @Test
  void roleCapabilitiesUserPermissions() {
    runFeatureTest("role-capabilities-user-permissions");
  }

  @Test
  void roleCapabilitySetsUserPermissions() {
    runFeatureTest("role-capability-sets-user-permissions");
  }
}
