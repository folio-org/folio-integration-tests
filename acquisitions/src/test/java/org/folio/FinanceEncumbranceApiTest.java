package org.folio;

import static org.folio.TestUtils.specifyRandomRunnerId;

import com.intuit.karate.junit5.Karate;

public class FinanceEncumbranceApiTest {

  @Karate.Test
  Karate orderTest() {
    specifyRandomRunnerId();
    return Karate.run("classpath:domain/mod-finance/scenario/transactions/encumbrances/encumbrances.feature");
  }
}
