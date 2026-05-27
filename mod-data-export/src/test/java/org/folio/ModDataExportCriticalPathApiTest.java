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
        try {
            runFeature("classpath:common/eureka/destroy-data.feature");
        } finally {
            super.afterAll();
        }
    }

    @Test
    @Order(16)
    void ExportInstanceConfigC431148Test() {
        runFeatureTest("export-for-instance-config-C431148");
    }

    @Test
    @Order(17)
    void ExportInstanceConfigCqlC432309Test() {
        runFeatureTest("export-for-instance-config-cql-C432309");
    }

    @Test
    @Order(18)
    void ExportHoldingConfigC432311Test() {
        runFeatureTest("export-for-holding-config-C432311");
    }

    @Test
    @Order(19)
    void ExportAuthorityConfigC432314Test() {
        runFeatureTest("export-authority-config-C432314");
    }

    @Test
    @Order(20)
    void NegativeConfigExportC432315Test() {
        runFeatureTest("negative-config-export-C432315");
    }
}
