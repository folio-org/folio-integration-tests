package org.folio;

import com.intuit.karate.junit5.Karate;

import static org.folio.TestUtils.runHook;

public class InvoicesApiTest {

  @Karate.Test
  Karate invoiceTest() {
    runHook();
    return Karate.run("classpath:domain/mod-invoice/invoice.feature");
  }
}
