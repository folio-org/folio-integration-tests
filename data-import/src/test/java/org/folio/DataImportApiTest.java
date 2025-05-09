package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "folijet", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Disabled("Migrated to Eureka")
class DataImportApiTest extends TestBase {
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
    void dataImportIntegrationTest() {
        runFeatureTest("data-import-integration");
    }

    @Test
    @Order(3)
    void orderImportTest() {
        runFeatureTest("data-import-orders");
    }

    @Test
    @Order(4)
    void dataImportLogDeletionTest() {
        runFeatureTest("data-import-delete-logs");
    }

    @Test
    @Order(5)
    void importHoldingsRecordsTest() {
        runFeatureTest("data-import-holdings-records");
    }

    @Test
    @Order(6)
    void importInvoiceTest() {
        runFeatureTest("import-edi-invoice");
    }

    @Test
    @Order(7)
    void importAuthorityRecordsTest() {
        runFeatureTest("data-import-authority-records");
    }

    @Test
    @Order(8)
    void importPolAndVrnMatchingTest() {
        runFeatureTest("pol-vrn-matching");
    }

    @Test
    void marcBibsCreateTest() {
        runFeatureTest("marc-bibs/create");
    }

    @Test
    void marcBibsUpdateTest() {
        runFeatureTest("marc-bibs/update");
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
            runFeature("classpath:common/destroy-data.feature");
        }
    }
}
