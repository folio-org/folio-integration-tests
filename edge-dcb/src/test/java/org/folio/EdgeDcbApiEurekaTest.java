package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "edge-dcb")
class EdgeDcbApiEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-dcb/eureka-features/";
    public EdgeDcbApiEurekaTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void testLendingFlow() {
        runFeatureTest("lending-flow-proxy.feature");
    }
//    @Test
//    void testBorrowingPickupFlow() {
//        runFeatureTest("borrowing-pickup-proxy.feature");
//    }
//
//    @Test
//    void testBorrowingFlow() {
//        runFeatureTest("borrowing-flow-proxy.feature");
//    }
//
//    @Test
//    void testPickupFlow() { runFeatureTest("pickup-flow-proxy.feature"); }
//    @BeforeAll
//    public void setup() {
//        runFeature("classpath:volaris/edge-dcb/edge-dcb-junit-eureka.feature");
//    }

//    @AfterAll
//    public void tearDown() {
//        runFeature("classpath:common/eureka/destroy-data.feature");
//    }


}
