package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-template-engine")
public class ModTemplateEngineTests extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:vega/mod-template-engine/features/";

  public ModTemplateEngineTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-template-engine/template-engine-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void templateRequestTest() {
    runFeatureTest("templateRequest");
  }

  @Test
  void templatesTest() {
    runFeatureTest("templates");
  }
}
