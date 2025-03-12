package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-gobi")
@Deprecated(forRemoval = true)
@Disabled
public class GobiApiTest extends TestBase{

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";

    public GobiApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void gobiApiTest() {
    runFeature("classpath:thunderjet/mod-gobi/gobi-junit.feature");
    }

}


