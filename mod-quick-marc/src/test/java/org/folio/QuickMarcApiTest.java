package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "spitfire", module = "mod-quick-marc")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class QuickMarcApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-quick-marc/features/";

    public QuickMarcApiTest() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    @Order(1)
    void testQuickMarcAuthorityRecordsFeature() {
        runFeatureTest("quick-marc-authority-records.feature");
    }

    @Test
    @Order(2)
    void testQuickMarcBibRecordsFeature() {
        runFeatureTest("quick-marc-bib-records.feature");
    }

    @Test
    @Order(3)
    void testQuickMarcHoldingsRecordsFeature() {
        runFeatureTest("quick-marc-holdings-records.feature");
    }

    @Test
    @Order(4)
    void testQuickMarcRecordStatusFeature() {
        runFeatureTest("quick-marc-record-status.feature");
    }

    @Test
    @Order(5)
    void testQuickMarcParallelUpdateOfLinkedAuthorityRecordsFeature() {
        runFeatureTest("quick-marc-update-linked-authority-records.feature", 2);
    }

    @Test
    @Order(6)
    void testQuickMarcLinkingRecordsFeature() {
        runFeatureTest("quick-marc-linking-records.feature");
    }

    @Test
    @Order(7)
    void testQuickMarcTagsOrderFeature() {
        runFeatureTest("quick-marc-tags-order.feature");
    }

    @Test
    @Order(8)
    void testQuickMarcHandleLiteralDollarFeature() {
        runFeatureTest("quick-marc-handle-literal-dollar.feature");
    }

    @BeforeAll
    public void quickMarcApiTestBeforeAll() {
        runFeature("classpath:spitfire/mod-quick-marc/quick-marc-junit.feature");
        runFeatureTest("setup/setup.feature");
    }

    @AfterAll
    public void quickMarcApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}
