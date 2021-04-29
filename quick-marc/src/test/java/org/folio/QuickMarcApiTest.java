package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class QuickMarcApiTest extends AbstractTestRailIntegrationTest {

    private static final String TEST_BASE_PATH = "classpath:domain/mod-quick-marc/features/";
    private static final String TEST_SUITE_NAME = "mod-quick-marc";
    private static final long TEST_SECTION_ID = 1326L;
    private static final long TEST_SUITE_ID = 48L;

    public QuickMarcApiTest() {
        super(new TestRailIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
    }

    @Test
    void testQuickMarcRecordsFeature() {
        runFeatureTest("quick-marc-records.feature");
    }

    @Test
    void testQuickMarcRecordStatusFeature() {
        runFeatureTest("quick-marc-record-status.feature");
    }

    @BeforeAll
    public void quickMarcApiTestBeforeAll() {
        runFeature("classpath:domain/mod-quick-marc/quick-marc-junit.feature");
    }

    @AfterAll
    public void quickMarcApiTestAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
