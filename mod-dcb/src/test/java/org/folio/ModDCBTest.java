package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
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
  void testLendingFlow() {  runFeatureTest("lending-flow.feature"); }

  @Test
  void testBorrowingPickupFlow() {
    runFeatureTest("borrowing-pickup.feature");
  }

  @Test
  void testBorrowingFlow() {
    runFeatureTest("borrowing-flow.feature");
  }

  @Test
  void testPickupFlow() { runFeatureTest("pickup-flow.feature"); }

  @Test
  void testCancelCirculationRequest() {
    runFeatureTest("cancelling-lending-flow.feature");
  }

  @Test
  void testCancelCirculationForBorrowingFlowRequest() {
    runFeatureTest("cancelling-flow-for-borrowing-pickup-flow.feature");
  }

  @Test
  void testCancelCirculationForBorrowerFlowRequest() {
    runFeatureTest("cancelling-flow-for-borrower-flow.feature");
  }

  @Test
  void testCancelCirculationForPickUpFlowRequest() {
    runFeatureTest("cancelling-flow-for-pickup-flow.feature");
  }
  @Test
  void testLendingFlowChainOfResponsibility() {  runFeatureTest("lending-flow-chain-of-responsibility.feature"); }

  @Test
  void testBorrowingFlowChainOfResponsibility() {  runFeatureTest("borrowing-flow-chain-of-responsibility.feature"); }

  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-dcb/mod-dcb-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }
}
