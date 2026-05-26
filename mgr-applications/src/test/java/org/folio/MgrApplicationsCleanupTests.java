package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@EnabledIfSystemProperty(named = "isolated.cleanup", matches = "true")
@FolioTest(team = "Eureka", module = "mgr-applications")
class MgrApplicationsCleanupTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mgr-applications/features/";
  private boolean initialized;

  MgrApplicationsCleanupTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void setup() {
    var environmentName = System.getProperty("karate.env");
    if ("snapshot".equals(environmentName) || "snapshot-2".equals(environmentName)) {
      Assertions.fail("Cleanup test is not allowed on shared snapshot environments");
    }

    runFeature("classpath:eureka/mgr-applications/init-cleanup-junit.feature");
    initialized = true;
  }

  @AfterAll
  void tearDown() {
    if (initialized) {
      runFeature("classpath:common/eureka/destroy-data.feature");
    }
  }

  @Test
  void applicationCleanup_isolatedScenario() {
    runFeatureTest("application-cleanup");
  }
}
