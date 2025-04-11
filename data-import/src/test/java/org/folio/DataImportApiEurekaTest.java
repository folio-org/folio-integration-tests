package org.folio;

import org.folio.test.TestBaseEureka;
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
@Disabled
class DataImportApiEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:folijet/data-import/eureka-features/";

    public DataImportApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    // creates a number of records which are assumed to be there in later tests
    @Test
    @Order(1)
    void createMarcRecordsTest() {
        runFeatureTest("create-marc-records.feature");
    }

    @Test
    @Order(2)
    void dataImportIntegrationTest() {
        runFeatureTest("data-import-integration.feature");
    }

    @Test
    @Order(3)
    void orderImportTest() {
        runFeatureTest("data-import-orders.feature");
    }

    @Test
    @Order(4)
    void dataImportLogDeletionTest() {
        runFeatureTest("data-import-delete-logs.feature");
    }

    @Test
    @Order(5)
    void importHoldingsRecordsTest() {
        runFeatureTest("data-import-holdings-records.feature");
    }

    // one still broken :(
    @Test
    @Order(6)
    void importInvoiceTest() {
        runFeatureTest("import-edi-invoice.feature");
    }

    @Test
    @Order(7)
    void importAuthorityRecordsTest() {
        runFeatureTest("data-import-authority-records.feature");
    }

    @Test
    @Order(8)
    void importPolAndVrnMatchingTest() {
        runFeatureTest("pol-vrn-matching.feature");
    }

    @Test
    void marcBibsCreateTest() {
        runFeatureTest("marc-bibs/create.feature");
    }

    @Test
    void marcBibsUpdateTest() {
        runFeatureTest("marc-bibs/update.feature");
    }

    @Test
    void importInstanceIdentifierMatchTest() {
        runFeatureTest("instance-identifier-match.feature");
    }

    @Test
    void importBibRecordsTest() {
        runFeatureTest("data-import-bib-records.feature");
    }

    @Test
    void fileExtensionsTest() {
        runFeatureTest("file-extensions.feature");
    }

    @Test
    void fileUploadTest() {
        runFeatureTest("file-upload.feature");
    }

    @Test
    void testSplitFeatureEnabledStatus() {
        runFeatureTest("split-feature-enabled.feature");
    }

    @Test
    void dataImportMultipleItemsTest() {
        runFeatureTest("data-import-multiple-records-from-marc-bib.feature");
    }

    @Test
    void dataImportSetForDeletion() {
        runFeatureTest("data-import-set-for-deletion.feature");
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            runFeature("classpath:folijet/data-import/data-import-junit-eureka.feature");
        }
    }

    @AfterAll
    public void teardown() {
        if (shouldCreateTenant()) {
            runFeature("classpath:common/eureka/destroy-data.feature");
        }
    }
}
