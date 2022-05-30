package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;
/**
 * NOTE: For this test suite to work,user "DIKU" should have all permissions
 */

@FolioTest(team = "thunderjet", module = "mod-gobi")
public class GobiApiTest extends TestBase{

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";

    public GobiApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }


    // Feature(s) list :
    @Test
    void runStubTest() {
    runFeature("classpath:thunderjet/mod-gobi/gobi.feature");
    }

}


