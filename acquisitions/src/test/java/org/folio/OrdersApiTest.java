package org.folio;

import static org.folio.TestUtils.specifyRandomRunnerId;

import com.intuit.karate.junit5.Karate;

public class OrdersApiTest {

  @Karate.Test
  Karate orderTest() {
    specifyRandomRunnerId();
    return Karate.run("classpath:domain/mod-orders/orders.feature");
  }
}
