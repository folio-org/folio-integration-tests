package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class ModDataExportApiTest extends AbstractTestRailIntegrationTest {

    private static final long TEST_SUITE_ID = 114L;
    private static final long TEST_SECTION_ID = 4517L;
    private static final String TEST_SUITE_NAME = "mod-data-export";
    private static final String TEST_BASE_PATH = "classpath:domain/dataexport/features/";

    public ModDataExportApiTest() {
        super(new TestRailIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
    }

    @Test
    void quickExportTest() {
        runFeatureTest("quick-export");
    }

    @BeforeAll
    public void modDataExportTestsBeforeAll() {
        runFeature("classpath:domain/dataexport/data-export-basic-junit.feature");
    }

    @AfterAll
    public void ordersApiTestAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
