package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;
@FolioTest(team = "volaris", module = "edge-dcb")
public class EdgeDcbApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-dcb/";
    public EdgeDcbApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void testGetDCBTransactionStatus() {
        runFeatureTest("dcb-transaction-status.feature");
    }
//    @Test
//    void testCreateDCBTransaction() {
//        runFeatureTest("create-dcb-transaction.feature");
//    }
//    @Test
//    void testUpdateDCBTransaction() {
//        runFeatureTest("update-dcb-transaction.feature");
//    }
}
