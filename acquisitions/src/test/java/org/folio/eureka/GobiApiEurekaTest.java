package org.folio.eureka;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
@Disabled
@FolioTest(team = "thunderjet", module = "mod-gobi")
public class GobiApiEurekaTest extends TestBaseEureka {

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/eureka/features/";

    public GobiApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void gobiApiTest() {
    runFeature("classpath:thunderjet/mod-gobi/eureka/gobi-junit.feature");
    }

}


