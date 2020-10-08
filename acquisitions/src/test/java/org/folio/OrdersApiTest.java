package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;
import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.Ignore;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class OrdersApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "mod-orders";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1388l;

  private static String TEST_BASE_PATH = "classpath:domain/mod-orders/features/";

  private static String TEST_CASE_NAME_1 = "close-order-when-fully-paid-and-received";
  private static String TEST_CASE_NAME_2 = "create-order-that-has-not-enough-money";
  private static String TEST_CASE_NAME_3 = "encumbrance-tags-inheritance";
  private static String TEST_CASE_NAME_4 = "expense-class-handling-for-order-and-lines";
  private static String TEST_CASE_NAME_5 = "increase-poline-quantity-for-open-order";

  public OrdersApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Ignore
  @Karate.Test
  Karate orderTest() {
    runHook();
    return Karate.run("classpath:domain/mod-orders/orders.feature");
  }

  @Test
  @Karate.Test
  void closeOrderWhenFullyPaidAndReceived() throws IOException {
    commonTestCase(TEST_CASE_NAME_1);
  }

  @Test
  void createOrderWithNotEnoughMoney() throws IOException {
    commonTestCase(TEST_CASE_NAME_2);
  }

  @Test
  void encumbranceTagsInheritance() throws IOException {
    commonTestCase(TEST_CASE_NAME_3);
  }

  @Test
  void expenseClassHandlingOrderWithLines() throws IOException {
    commonTestCase(TEST_CASE_NAME_4);
  }

  @Test
  void increasePolineQuantityOpenOrder() throws IOException {
    commonTestCase(TEST_CASE_NAME_5);
  }

  @BeforeAll
  public static void ordersApiTestBeforeAll() {
    Karate.run("classpath:domain/mod-orders/orders.feature");
  }

  @AfterAll
  public static void ordersApiTestAfterAll() {
    Karate.run("classpath:common/destroy-data.feature");
  }

}