package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class DataImportApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:domain/data-import/features/";

    public DataImportApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:domain/data-import/data-import.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void dataImportIntegrationTest() {
        runFeatureTest("data-import-integration");
    }

    @Test
    void fileExtensionsTest() {
        runFeatureTest("file-extensions");
    }

    @Test
    void fileUploadTest() {
        runFeatureTest("file-upload");
    }

}
