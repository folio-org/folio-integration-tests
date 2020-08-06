package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;

public class FinanceApiTest {

  @Karate.Test
  Karate financeTest() {
    runHook();
    return Karate.run("classpath:domain/mod-finance/finance.feature");
  }
}
