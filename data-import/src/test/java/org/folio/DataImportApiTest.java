package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@FolioTest(team = "folijet", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataImportApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:folijet/data-import/features/";

    public DataImportApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void dataImportMappingRuleChange() {
        feature("classpath:folijet/data-import/FAT-1117.feature")
                .run();
    }

    @Test
    void dataImportModCopyCat() {
        feature("classpath:folijet/data-import/mod-copycat.feature")
                .run();
    }

    @Test
    void dataImportTest() {
        feature("classpath:folijet/data-import/features/")
                .threadCount(3)
                .run();
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            feature("classpath:folijet/data-import/data-import-junit.feature")
                    .reportDir(timestampedReportDir())
                    .run();
        }
        feature("classpath:folijet/data-import/global/create-marc-records.feature")
                .reportDir(timestampedReportDir())
                .run();
    }

    @AfterAll
    public void teardown() {
        if (shouldCreateTenant()) {
            feature("classpath:common/eureka/destroy-data.feature")
                    .reportDir(timestampedReportDir())
                    .run();
        }
    }
}
