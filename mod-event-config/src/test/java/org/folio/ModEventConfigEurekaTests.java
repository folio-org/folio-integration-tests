package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;

@Disabled
@FolioTest(team = "volaris", module = "mod-event-config")
public class ModEventConfigEurekaTests extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:vega/mod-event-config/eureka-features/";

  public ModEventConfigEurekaTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-event-config/event-config-junit-eureka.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void eventConfigTest() {
    runFeatureTest("eventConfig");
  }
}
