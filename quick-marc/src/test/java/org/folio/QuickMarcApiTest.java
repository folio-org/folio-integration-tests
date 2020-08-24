package org.folio;

import static org.folio.TestUtils.runHook;

import com.intuit.karate.junit5.Karate;

public class QuickMarcApiTest {

    @Karate.Test
    Karate quickMarcTest() {
        runHook();
        return Karate.run("classpath:domain/mod-quick-marc/quickMarc.feature");
    }
}
