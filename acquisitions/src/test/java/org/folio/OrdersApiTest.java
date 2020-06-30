package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;

public class OrdersApiTest {

  @Karate.Test
  Karate orderTest() {
    runHook();
    return Karate.run("classpath:domain/mod-orders/orders.feature");
  }
}
