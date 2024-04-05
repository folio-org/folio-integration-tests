package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "Odin", module = "mod-batch-print")
class BatchPrintApiTests extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:odin/mod-batch-print/features/";

    public BatchPrintApiTests() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:odin/mod-batch-print/batch-print-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void emailTest() {
        runFeatureTest("batch-print");
    }

}
