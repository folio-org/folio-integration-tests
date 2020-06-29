package org.folio;

import com.intuit.karate.junit5.Karate;

import static org.folio.TestUtils.specifyRandomRunnerId;

public class InvoicesApiTest {

  @Karate.Test
  Karate invoiceTest() {
    specifyRandomRunnerId();
    return Karate.run("classpath:domain/mod-invoice/invoice.feature");
  }
}
