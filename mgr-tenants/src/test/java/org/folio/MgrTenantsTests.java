package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "mgr-tenants")
class MgrTenantsTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mgr-tenants/features/";

  MgrTenantsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void setup() {
    runFeature("classpath:eureka/mgr-tenants/mgr-tenants-junit.feature");
  }

  @Test
  void listTenants() {
    runFeatureTest("list-tenants");
  }
}
