package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-dcb")
public class ModDCBTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-dcb/features/";

  public ModDCBTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @Test
  void testLendingFlow() {  runFeatureTest("lending-flow.feature"); }

  @Test
  void testLendingPatronsWithLocalNames() {
    runFeatureTest("lending-patrons-with-local-names.feature");
  }

  @Test
  void testBorrowingPickupFlow() {
    runFeatureTest("borrowing-pickup.feature");
  }

  @Test
  void testBorrowingFlow() {
    runFeatureTest("borrowing-flow.feature");
  }

  @Test
  void testRefreshShadowLocations() {
    runFeatureTest("refresh-shadow-locations.feature");
  }

  @Test
  void testBorrowingFlexibleLocations() {
    runFeatureTest("borrowing-flexible-locations.feature");
  }

  @Test
  void testPickupFlexibleLocations() {
    runFeatureTest("pickup-flexible-locations.feature");
  }

  @Test
  void testPickupFlow() { runFeatureTest("pickup-flow.feature"); }

  @Test
  void testPickupPatronsWithLocalNames() {
    runFeatureTest("pickup-patrons-with-local-names.feature");
  }

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

    @Test
    void testRefreshDcbShadowLocations() { runFeatureTest("refresh-dcb-shadow-locations.feature"); }

    @Test
    void testShadowLocationsCreatedViaApi() { runFeatureTest("shadow-locations-created-via-api.feature"); }

    @Test
    void testEcsShadowLocationsNotDisplayed() { runFeatureTest("ecs-shadow-locations-not-displayed.feature"); }

    @Test
  void testExpirationLendingFlow() { runFeatureTest("expiration-lending-flow.feature"); }

  @Test
  void testExpirationBorrowerFlow() { runFeatureTest("expiration-borrower-flow.feature"); }

  @Test
  void testExpirationPickupFlow() { runFeatureTest("expiration-pickup-flow.feature"); }

  @Test
  void testExpirationBorrowingPickupFlow() { runFeatureTest("expiration-borrowing-pickup-flow.feature"); }

  @Test
  void testBorrowingPickupUpdateWithPatronNotice() {
    runFeatureTest("borrowing-pickup-update-with-patron-notice.feature");
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-dcb/mod-dcb-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }
}
