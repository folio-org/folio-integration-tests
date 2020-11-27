package org.folio;

import static org.folio.testrail.config.TestConfigurationEnum.ORDERS_CONFIGURATION;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class OrdersApiTest extends AbstractTestRailIntegrationTest {

  public OrdersApiTest() {
    super(new TestRailIntegrationService(ORDERS_CONFIGURATION));
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
  void changeMultyLocationForPOL() {
    runFeatureTest("check-pieces-item-holdings-when-pol-one-location-only-change");
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
