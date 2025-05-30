package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-data-export-spring")
public class DataExportSpringApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-data-export-spring/features/";

    public DataExportSpringApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }


    @Test
    void rootTest() {
        runFeature("classpath:thunderjet/mod-data-export-spring/data-export-spring.feature");
    }

}
