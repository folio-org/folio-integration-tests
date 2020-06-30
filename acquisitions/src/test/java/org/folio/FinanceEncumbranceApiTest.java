package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;

public class FinanceEncumbranceApiTest {

  @Karate.Test
  Karate orderTest() {
    runHook();
    return Karate.run("classpath:domain/mod-finance/scenario/transactions/encumbrances/encumbrances.feature");
  }
}
