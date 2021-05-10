package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class QuickMarcApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:domain/mod-quick-marc/features/";

    public QuickMarcApiTest() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
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
