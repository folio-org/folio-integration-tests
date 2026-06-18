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
public class ModDataExportExtendedApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/dataexport/features/";

    public ModDataExportExtendedApiTest() {
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
    void testExportC15847() {
        runFeatureTest("export-for-cql-C15847.feature");
    }

    @Test
    void testExportC350511() {
        runFeatureTest("export-for-holdings-default-mapping-C350511.feature");
    }

    @Test
    void testExportC350518() {
        runFeatureTest("export-for-holdings-C350518.feature");
    }
}
