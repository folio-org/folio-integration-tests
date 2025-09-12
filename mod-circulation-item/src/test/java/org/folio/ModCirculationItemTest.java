package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-circulation-item")
public class ModCirculationItemTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-circulation-item/features/";

  public ModCirculationItemTest() {
    super(
        new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @Test
  void testRefreshShadowLocations() {
    runFeatureTest("circulation-item-flow.feature");
  }


  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-circulation-item/mod-circulation-item-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }
}
