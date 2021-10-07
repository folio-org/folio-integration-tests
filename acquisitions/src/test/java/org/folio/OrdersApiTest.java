package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

public class OrdersApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-orders/features/";

  public OrdersApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void deleteFundDistribution() {
    runFeatureTest("delete-fund-distribution");
  }

  @Test
  void deleteOpenedOrderAndOrderLines() {
    runFeatureTest("delete-opened-order-and-lines.feature");
  }

  @Test
  void closeOrderWhenFullyPaidAndReceived() {
    runFeatureTest("close-order-when-fully-paid-and-received");
  }

  @Test
  void createOrderWithNotEnoughMoney() {
    runFeatureTest("create-order-that-has-not-enough-money");
  }

  @Test
  void encumbranceTagsInheritance() {
    runFeatureTest("encumbrance-tags-inheritance");
  }

  @Test
  void expenseClassHandlingOrderWithLines() {
    runFeatureTest("expense-class-handling-for-order-and-lines");
  }

  @Test
  void increasePolineQuantityOpenOrder() {
    runFeatureTest("increase-poline-quantity-for-open-order");
  }

  @Test
  void openOrderWithDifferentPoLineCurrency() {
    runFeatureTest("open-order-with-different-po-line-currency");
  }
  
  @Test
  void checkOrderNeedReEncumber() {
    runFeatureTest("check-re-encumber-property");
  }

  @Test
  void openOrderWithManualExchangeRate() {
    runFeatureTest("open-order-with-manual-exchange-rate");
  }


  @Test
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest("check-order-re-encumber-work-correctly");
  }

  @Test
  void openOngoingOrder() {
    runFeatureTest("open-ongoing-order");
  }

  @Disabled
  @Test
  void checkOrderLinesNumberRetrieveLimit() {
    runFeatureTest("check-order-lines-number-retrieve-limit");
  }

  @Test
  void checkNewTagsCreatedInCentralTagRepository() {
    runFeatureTest("check-new-tags-in-central-tag-repository");
  }

  @Test
  void closeOrderAndReleaseEncumbrances() {
    runFeatureTest("close-order-and-release-encumbrances");
  }

  @Test
  void openOngoingOrderShouldFailIfIntervalOrRenewalDateNotSet() {
    runFeatureTest("open-ongoing-order-should-fail-if-interval-or-renewaldate-notset");
  }

  @Test
  void openOrderFailureSideEffects() {
    runFeatureTest("open-order-failure-side-effects");
  }

  @Test
  void openOrderInstanceLink() {
    runFeatureTest("open-order-instance-link");
  }

  @Test
  void openOrderWithoutHoldings() {
    runFeatureTest("open-order-without-holdings");
  }

  @Test
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest("open-order-with-the-same-fund-distributions");
  }

  @Test
  void receivePieceAgainstNonPackagePol() {
    runFeatureTest("receive-piece-against-non-package-pol");
  }

  @Test
  void receivePieceAgainstPackagePol() {
     runFeatureTest("receive-piece-against-package-pol");
  }

  @Test
  void createAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsFalse() {
    runFeatureTest("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false");
  }

  @Test
  void createAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsTrue() {
    runFeatureTest("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true");
  }


  @BeforeAll
  public void ordersApiTestBeforeAll() {
    runFeature("classpath:domain/mod-orders/orders-junit.feature");
  }

  @AfterAll
  public void ordersApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
