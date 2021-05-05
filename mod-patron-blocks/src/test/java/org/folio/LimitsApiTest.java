package org.folio;

import static org.folio.TestUtils.specifyRandomRunnerId;

import com.intuit.karate.junit5.Karate;

class LimitsApiTest {

  @Karate.Test
  Karate limitsTest() {
    specifyRandomRunnerId();
    return Karate.run("classpath:domain/mod-patron-blocks/features/limits.feature");
  }
}
