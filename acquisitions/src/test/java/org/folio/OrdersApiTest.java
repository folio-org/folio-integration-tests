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
  void checkEncumbrancesAfterOrderIsReopened() {
    runFeatureTest("check-encumbrances-after-order-is-reopened.feature");
  }

  @Test
  void checkEncumbrancesAfterOrderIsReopened2() {
    runFeatureTest("check-encumbrances-after-order-is-reopened-2.feature");
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
  void changeOneLocationForPOL() {
    runFeatureTest("check-pieces-item-holdings-when-pol-multy-location-only-change");
  }
  
  @Test
  void changeMultiLocationForPOL() {
    runFeatureTest("check-pieces-item-holdings-when-pol-one-location-only-change");
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
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest("open-order-with-the-same-fund-distributions");
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
