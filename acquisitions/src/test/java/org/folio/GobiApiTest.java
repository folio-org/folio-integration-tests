package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;

public class GobiApiTest extends TestBase{

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:domain/mod-gobi/features/";

    public GobiApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void gobiApiTestBeforeAll() {
        runFeature("classpath:domain/mod-gobi/gobi-junit.feature");
    }

    @AfterAll
    public void gobiApiTestAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }

    // Feature(s) list :

}


