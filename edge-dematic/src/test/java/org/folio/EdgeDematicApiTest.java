package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EdgeDematicApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/edge-dematic/features/";

  public EdgeDematicApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
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
