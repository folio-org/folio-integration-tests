package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "folijet", module = "data-import-large-scale-tests")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataImportLargeScaleTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:folijet/data-import-large-scale-tests/features/";

    public DataImportLargeScaleTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    @Order(1)
    void createMarcRecordsTest() {
        runFeatureTest("create-instance");
    }

    @BeforeAll
    public void setup() {
//        if (shouldCreateTenant()) {
//            runFeature("classpath:folijet/data-import/data-import-junit.feature");
//        }
    }

//    @AfterAll
//    public void teardown() {
//        if (shouldCreateTenant()) {
//            runFeature("classpath:common/destroy-data.feature");
//        }
//    }
}
