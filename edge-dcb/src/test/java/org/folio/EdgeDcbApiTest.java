package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
@FolioTest(team = "volaris", module = "edge-dcb")
public class EdgeDcbApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-dcb/features/";
    public EdgeDcbApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void testGetDCBTransactionStatus() {
        runFeatureTest("get-dcb-transaction-status.feature");
    }

//    @Test
//    void testCreateDCBTransaction() {
//        runFeatureTest("create-dcb-transaction.feature");
//    }
//    @Test
//    void testUpdateDCBTransaction() {
//        runFeatureTest("update-dcb-transaction.feature");
//    }

    //commenting this setup and tearDown part because as of now we are not preparing any data

//    @BeforeAll
//    public void setup() {
//        runFeature("classpath:volaris/edge-dcb/edge-dcb-junit.feature");
//    }

//    @AfterAll
//    public void tearDown() {
//        runFeature("classpath:common/destroy-data.feature");
//    }
}
