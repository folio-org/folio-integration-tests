package org.folio;

import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class OrdersApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-orders";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1388l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-orders/features/";

  public OrdersApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Test
  void closeOrderWhenFullyPaidAndReceived() throws IOException {
    runFeatureTest("close-order-when-fully-paid-and-received");
  }

  @Test
  void createOrderWithNotEnoughMoney() throws IOException {
    runFeatureTest("create-order-that-has-not-enough-money");
  }

  @Test
  void encumbranceTagsInheritance() throws IOException {
    runFeatureTest("encumbrance-tags-inheritance");
  }

  @Test
  void expenseClassHandlingOrderWithLines() throws IOException {
    runFeatureTest("expense-class-handling-for-order-and-lines");
  }

  @Test
  void increasePolineQuantityOpenOrder() throws IOException {
    runFeatureTest("increase-poline-quantity-for-open-order");
  }

  @BeforeAll
  public static void ordersApiTestBeforeAll() {
    runFeature("classpath:domain/mod-orders/orders-junit.feature");

  }

  @AfterAll
  public static void ordersApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
