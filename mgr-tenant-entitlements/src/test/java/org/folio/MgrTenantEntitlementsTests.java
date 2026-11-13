package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "mgr-tenant-entitlements")
class MgrTenantEntitlementsTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mgr-tenant-entitlements/features/";

  MgrTenantEntitlementsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void setup() {
    runFeature("classpath:eureka/mgr-tenant-entitlements/mgr-tenant-entitlements-junit.feature");
  }

  @AfterAll
  void cleanup() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void listEntitlements() {
    runFeatureTest("list-entitlements");
  }

  @Test
  void entitlementApplication() {
    runFeatureTest("entitlement-application");
  }

  @Test
  void entitlementModule() {
    runFeatureTest("entitlement-module");
  }

  @Test
  void entitlementValidation() {
    runFeatureTest("entitlement-validation");
  }

  @Test
  void entitlementTenantAccess() {
    runFeatureTest("entitlement-tenant-access");
  }

  @Test
  void asyncEntitlementProcessingFeedbackLoop() {
    runFeatureTest("async-entitlement-processing-feedback-loop");
  }

  @Test
  void entitleModuleWithoutProvides() {
    runFeatureTest("entitle-module-without-provides");
  }

  @Test
  void sharedModuleApplicationUpgrade() {
    runFeatureTest("shared-module-application-upgrade");
  }

  @Test
  @Disabled("Entitlement rejects a module version used by a differently named application")
  void splitApplicationSameModuleVersion() {
    runFeatureTest("split-application-same-module-version");
  }

  @Test
  void splitApplicationDifferentModuleVersion() {
    runFeatureTest("split-application-different-module-version");
  }

  @Test
  void platformEntitlement() {
    runFeatureTest("platform-entitlement");
  }
}

