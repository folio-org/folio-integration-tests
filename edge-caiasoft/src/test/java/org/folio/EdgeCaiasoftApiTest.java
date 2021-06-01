package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

public class EdgeCaiasoftApiTest extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/edge-caiasoft/features/";

  public EdgeCaiasoftApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void testReturnShouldChangeItemStatusToAvailableIfNoHoldRequestExists() {
    runFeatureTest("return-should-change-item-status-to-available-when-no-hold-request-exists");
  }

  @Test
  void testReturnShouldCreateRetrievalQueueRecordIfHoldRequestExists() {
    runFeatureTest("return-should-create-retrieval-queue-record-when-hold-request-exists");
  }
}
