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

@FolioTest(team = "firebird", module = "data-export-spring")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ModDataExportSpringApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:firebird/dataexportspring/features/";

    public ModDataExportSpringApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }
    @Test
    void jobDataExportSpring() {
        runFeatureTest("job-data-export-spring");
    }

    @BeforeAll
    public void modDataExportTestsBeforeAll() {
        runFeature("classpath:firebird/dataexportspring/data-export-spring-basic-junit.feature");
    }

}