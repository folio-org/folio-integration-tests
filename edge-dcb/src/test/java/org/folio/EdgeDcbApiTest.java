package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

//@Disabled
@FolioTest(team = "volaris", module = "edge-dcb")
public class EdgeDcbApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-dcb/features/";
    public EdgeDcbApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void testGetDCBTransactionStatus() {
        runFeatureTest("lending-flow-proxy.feature");
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:volaris/edge-dcb/edge-dcb-junit.feature");
    }
    
}
