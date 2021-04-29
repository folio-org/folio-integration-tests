package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.Test;

class LimitsApiTest extends AbstractTestRailIntegrationTest {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-patron-blocks/patron-block-limits/";
  private static final String TEST_SUITE_NAME = "mod-patron-blocks";
  private static final long TEST_SECTION_ID = 11064L;
  private static final long TEST_SUITE_ID = 708L;

  public LimitsApiTest() {
    super(new TestRailIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
  }

  @Test
  void limits() {
    runFeatureTest("limits.feature");
  }
}
