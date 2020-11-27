package org.folio;

import com.intuit.karate.junit5.Karate;
import static org.folio.TestUtils.runHook;

public class DataImportApiTest {

    @Karate.Test
    Karate dataImportTest() {
        runHook();
        return Karate.run("classpath:domain/data-import/data-import.feature");
    }
}
