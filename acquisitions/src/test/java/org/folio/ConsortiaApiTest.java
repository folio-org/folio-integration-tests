package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-consortia")
public class ConsortiaApiTest extends TestBase {

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-consortia/features/";

    public ConsortiaApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    public void consortiaApiTest() {
        runFeature("classpath:thunderjet/mod-consortia/consortia-junit.feature");
    }

}


