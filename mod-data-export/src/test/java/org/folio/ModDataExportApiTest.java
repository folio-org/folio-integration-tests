package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ModDataExportApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:domain/dataexport/features/";

    public ModDataExportApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    @Order(1)
    void quickExportTest() {
        runFeatureTest("quick-export");
    }

    @Test
    @Order(2)
    void deleteJobExecutionTest() {
        runFeatureTest("delete-job-execution");
    }

    @Test
    @Order(3)
    void mappingProfilesTest() {
        runFeatureTest("mapping-profiles");
    }

    @Test
    @Order(4)
    void jobProfilesTest() {
        runFeatureTest("job-profiles");
    }

    @Test
    @Order(4)
    void fileUploadAndExportTest() {
        runFeatureTest("export.feature");
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
