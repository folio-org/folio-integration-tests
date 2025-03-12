package org.folio;

import static org.folio.TestUtils.specifyRandomRunnerId;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Disabled;

@Disabled
public class FinanceApiTest {

  @Karate.Test
  Karate financesTest() {
    specifyRandomRunnerId();
    return Karate.run("classpath:domain/mod-finance/finance.feature");
  }
}
