package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "citation", module = "mod-linked-data")
class CreateResourceTest extends TestBase {

  private static final String TEST_BASE_PATH =
    "classpath:citation/mod-linked-data/features/create-resource/";

  public CreateResourceTest() {
    super(
      new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:citation/mod-linked-data/linked-data-junit.feature");
    runFeature(TEST_BASE_PATH + "create-ref-data.feature");
    runFeature(TEST_BASE_PATH + "create-resource.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void testSearchOutbound() {
    runFeatureTest("search-outbound");
  }

  @Test
  void testInventoryOutbound() {
    runFeatureTest("inventory-outbound");
  }
}
