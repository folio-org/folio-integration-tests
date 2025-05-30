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

    // creates a number of records which are assumed to be there in later tests
    @Test
    @Order(1)
    void createMarcRecordsTest() {
        runFeatureTest("create-marc-records");
    }

    @Test
    @Order(2)
    void orderImportTest() {
        runFeatureTest("data-import-orders");
    }

    @Test
    @Order(3)
    void dataImportLogDeletionTest() {
        runFeatureTest("data-import-delete-logs");
    }

    @Test
    @Order(4)
    void importHoldingsRecordsTest() {
        runFeatureTest("data-import-holdings-records");
    }

    // one still broken :(
    @Test
    @Order(5)
    void importInvoiceTest() {
        runFeatureTest("import-edi-invoice");
    }

    @Test
    @Order(6)
    void importAuthorityRecordsTest() {
        runFeatureTest("data-import-authority-records");
    }

    @Test
    @Order(7)
    void importPolAndVrnMatchingTest() {
        runFeatureTest("pol-vrn-matching");
    }

    @Test
    void marcRecordsTest() {
        runFeatureTest("marc-records/all");
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

    @Test
    void dataImportSetForDeletion() {
        runFeatureTest("data-import-set-for-deletion");
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
