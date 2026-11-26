package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Eureka", module = "mod-okapi-facade")
class ModOkapiFacadeTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:eureka/mod-okapi-facade/features/";
  private boolean initialized;

  ModOkapiFacadeTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void setup() {
    runFeature("classpath:eureka/mod-okapi-facade/mod-okapi-facade-junit.feature");
    initialized = true;
  }

  @AfterAll
  void tearDown() {
    if (initialized) {
      runFeature("classpath:common/eureka/destroy-data.feature");
    }
  }

  @Test
  void tenantModules() {
    runFeatureTest("tenant-modules");
  }

  @Test
  void tenantInterfaces() {
    runFeatureTest("tenant-interfaces");
  }
}
