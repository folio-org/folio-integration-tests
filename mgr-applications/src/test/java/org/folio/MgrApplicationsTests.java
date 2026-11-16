package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "mgr-applications")
class MgrApplicationsTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mgr-applications/features/";

  MgrApplicationsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void applications() {
    runFeatureTest("applications");
  }

  @Test
  void validation() {
    runFeatureTest("validation");
  }

  @Test
  void applicationDiscovery() {
    runFeatureTest("application-discovery");
  }

  @Test
  void moduleDiscovery() {
    runFeatureTest("module-discovery");
  }

  @Test
  void moduleBootstrap() {
    runFeatureTest("module-bootstrap");
  }

  @Test
  void interfaceProvidedAndConsumed() {
    runFeatureTest("interface-provided-and-consumed");
  }
}
