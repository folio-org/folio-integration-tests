package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "citation", module = "mod-linked-data")
class ModLinkedDataTest extends TestBase {

  private static final String TEST_BASE_PATH =
    "classpath:citation/mod-linked-data/features/";

  public ModLinkedDataTest() {
    super(
      new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:citation/mod-linked-data/linked-data-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void testCreateResource() {
    runFeatureTest("create-resource");
  }
}
