package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "edge-dcb")
class EdgeDcbApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-dcb/features/";
    public EdgeDcbApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void testLendingFlow() {
        runFeatureTest("lending-flow-proxy.feature");
    }
    @Test
    void testBorrowingPickupFlow() {
        runFeatureTest("borrowing-pickup-proxy.feature");
    }

    @Test
    void testBorrowingFlow() {
        runFeatureTest("borrowing-flow-proxy.feature");
    }

    @Test
    void testPickupFlow() { runFeatureTest("pickup-flow-proxy.feature"); }
    @BeforeAll
    public void setup() {
        runFeature("classpath:volaris/edge-dcb/edge-dcb-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }


}
