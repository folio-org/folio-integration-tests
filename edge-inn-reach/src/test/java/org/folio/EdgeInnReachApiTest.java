package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "edge-inn-reach")
public class EdgeInnReachApiTest extends TestBase{
    // default module settings
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-inn-reach/features/";

    public EdgeInnReachApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void testGetToken() {
        runFeatureTest("get-token.feature");
    }

    @Override
    public void runHook() {
        super.runHook();
        System.setProperty("testTenant", "diku");
    }
}
