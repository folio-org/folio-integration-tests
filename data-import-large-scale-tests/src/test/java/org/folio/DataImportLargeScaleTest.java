package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.MethodOrderer;
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
    void createInstanceTest() {
        runFeatureTest("marc-bib/create/create-instance");
    }

}
