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

@FolioTest(team = "firebird", module = "data-export")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ModDataExportApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/dataexport/features/";

    public ModDataExportApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modDataExportTestsBeforeAll() {
        runFeature("classpath:firebird/dataexport/data-export-basic-junit.feature");
    }

    @AfterAll
    public void ordersApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    @Order(7)
    void quickExportTest() {
        runFeatureTest("quick-export");
    }

    @Test
    @Order(1)
    void mappingProfilesTest() {
        runFeatureTest("mapping-profiles");
    }

    @Test
    @Order(2)
    void jobProfilesTest() {
        runFeatureTest("job-profiles");
    }

    @Test
    @Order(3)
    void fileUploadAndExportTest() {
        runFeatureTest("export");
    }

    @Test
    @Order(4)
    void fileUploadAndExportWithSuppressTest() {
        runFeatureTest("suppress");
    }

    @Test
    @Order(6)
    void fileUploadAndExportForCqlTest() {
        runFeatureTest("export-for-cql");
    }

    @Test
    @Order(5)
    void fileExportForMarcHoldingRecordExportTest() {
        runFeatureTest("export-for-holdings");
    }

    @Test
    @Order(13)
    void fileExportForMarcInstanceRecordExportTest() {
        runFeatureTest("export-for-instances-default-mapping");
    }

    @Test
    @Order(14)
    void fileExportForDefaultHoldingRecordExportTest() {
        runFeatureTest("export-for-holdings-default-mapping");
    }

    @Test
    @Order(8)
    void fileExportForMarcAuthorityRecordExportTest() {
        runFeatureTest("export-for-authority");
    }

    @Test
    @Order(9)
    void deleteJobExecutionTest() {
        runFeatureTest("delete-job-execution");
    }

    @Test
    @Order(10)
    void authUpdateHeadingsExportTest() {
        runFeatureTest("export-auth-update-headings");
    }

    @Test
    @Order(11)
    void dataExportWithConsortiaTest() {
        runFeatureTest("consortia-export");
    }

    @Test
    @Order(12)
    void dataExportDeletedMarcIdsTest() {
        runFeatureTest("export-deleted-marc-ids");
    }

    @Test
    @Order(15)
    void dataExportDeletedAuthoritiesTest() {
        runFeatureTest("export-deleted-authorities");
    }
}
