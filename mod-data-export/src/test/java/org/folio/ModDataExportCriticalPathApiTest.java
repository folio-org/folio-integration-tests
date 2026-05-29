package org.folio;


import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "firebird", module = "data-export")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ModDataExportCriticalPathApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/dataexport/features/";

    public ModDataExportCriticalPathApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
    }

    @BeforeAll
    public void modDataExportTestsBeforeAll() {
        runFeature("classpath:firebird/dataexport/data-export-basic-junit.feature");
    }

    @AfterAll
    public void modDataExportTestsAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    @Order(1)
    void fileExportForMarcAuthorityRecordExportTest() {
        runFeatureTest("export-for-authority");
    }

    @Test
    @Order(2)
    void ExportInstanceConfigC431148Test() {
        runFeatureTest("export-for-instance-config-C431148");
    }

    @Test
    @Order(3)
    void ExportInstanceConfigCqlC432309Test() {
        runFeatureTest("export-for-instance-config-cql-C432309");
    }

    @Test
    @Order(4)
    void ExportHoldingConfigC432311Test() {
        runFeatureTest("export-for-holding-config-C432311");
    }

    @Test
    @Order(5)
    void ExportAuthorityConfigC432314Test() {
        runFeatureTest("export-authority-config-C432314");
    }

    @Test
    @Order(6)
    void NegativeConfigExportC432315Test() {
        runFeatureTest("negative-config-export-C432315");
    }
}
