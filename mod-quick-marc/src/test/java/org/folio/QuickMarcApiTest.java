package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "mod-quick-marc")
class QuickMarcApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-quick-marc/features/";

    public QuickMarcApiTest() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void testQuickMarcAuthorityRecordsFeature() {
        runFeatureTest("quick-marc-authority-records.feature");
    }

    @Test
    void testQuickMarcBibRecordsFeature() {
        runFeatureTest("quick-marc-bib-records.feature");
    }

    @Test
    void testQuickMarcHoldingsRecordsFeature() {
        runFeatureTest("quick-marc-holdings-records.feature");
    }

    @Test
    void testQuickMarcRecordStatusFeature() {
        runFeatureTest("quick-marc-record-status.feature");
    }

    @Test
    void testQuickMarcLinkingRecordsFeature() {
        runFeatureTest("quick-marc-linking-records.feature");
    }

    @BeforeAll
    public void quickMarcApiTestBeforeAll() {
        runFeature("classpath:spitfire/mod-quick-marc/quick-marc-junit.feature");
        runFeatureTest("setup/setup.feature");
    }

    @AfterAll
    public void quickMarcApiTestAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
