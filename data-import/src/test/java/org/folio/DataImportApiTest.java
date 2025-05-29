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

@FolioTest(team = "folijet", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataImportApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:folijet/data-import/features/";

    public DataImportApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    
    @Test
    @Order(1)
    void dataImportTest() {
        runFeatureTest("all");
    }

    @Test
    void importInstanceIdentifierMatchTest() {
        runFeatureTest("instance-identifier-match");
    }

    @Test
    void importBibRecordsTest() {
        runFeatureTest("data-import-bib-records");
    }

    @Test
    void fileExtensionsTest() {
        runFeatureTest("file-extensions");
    }

    @Test
    void fileUploadTest() {
        runFeatureTest("file-upload");
    }

    @Test
    void testSplitFeatureEnabledStatus() {
        runFeatureTest("split-feature-enabled");
    }

    @Test
    void dataImportMultipleItemsTest() {
        runFeatureTest("data-import-multiple-records-from-marc-bib");
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            runFeature("classpath:folijet/data-import/data-import-junit.feature");
        }
    }

    @AfterAll
    public void teardown() {
        if (shouldCreateTenant()) {
            runFeature("classpath:common/eureka/destroy-data.feature");
        }
    }
}
