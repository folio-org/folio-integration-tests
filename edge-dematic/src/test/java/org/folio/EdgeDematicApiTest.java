package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EdgeDematicApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/edge-dematic/features/";
  private static final String TEST_SUITE_NAME = "edge-dematic";
  private static final long TEST_SECTION_ID = 3347L;
  private static final long TEST_SUITE_ID = 161L;

  public EdgeDematicApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
  }

  @BeforeAll
  public void edgeDematicTestBeforeAll() {
    runFeature("classpath:domain/edge-dematic/edge-dematic-junit.feature");
  }

  @AfterAll
  public void edgeDematicTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }


  @Test
  void testLookupNewAsrItems() {
    runFeatureTest("lookup-new-asr-items.feature");
  }

  @Test
  void testLookupAsrRequests() {
    runFeatureTest("lookup-asr-requests.feature");
  }

  @Test
  void testASRItemStatusBeingRetrieved() {
    runFeatureTest("update-asr-item-being-retrieved.feature");
  }

  @Test
  void testASRItemStatusAvailable() {
    runFeatureTest("update-asr-item-status-available.feature");
  }
}
