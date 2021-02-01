package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class OrdersApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-orders/features/";
  private static final String TEST_SUITE_NAME = "mod-orders";
  private static final long TEST_SECTION_ID = 3337L;
  // TODO: make TEST_SUITE_ID different for each module
  private static final long TEST_SUITE_ID = 159L;

  public OrdersApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
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
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest("check-order-re-encumber-work-correctly");
  }

  @Test
  void openOngoingOrder() {
    runFeatureTest("open-ongoing-order");
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
