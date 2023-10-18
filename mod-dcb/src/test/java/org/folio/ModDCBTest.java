package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-dcb")
public class ModDCBTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-dcb/features/";

  public ModDCBTest() {
    super(
        new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
    );
  }

  @Test
  void testGetTransactionStatusById() {
    runFeatureTest("get-transaction-status-by-id.feature");
  }

  /*@Test
  void testCreateCirculationRequest() {
    runFeatureTest("create-circulation-request.feature");
  }

  @Test
  void testUpdateTransactionStatus() {
    runFeatureTest("update-transaction-status.feature");
  }*/


  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-dcb/mod-dcb-junit.feature");
  }

 /* @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }*/

}
