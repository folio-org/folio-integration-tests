package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
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

  @Test
  void listEntitlements() {
    runFeatureTest("list-entitlements");
  }
}
