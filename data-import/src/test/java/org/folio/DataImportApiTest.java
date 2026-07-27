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

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

@FolioTest(team = "promin", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataImportApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";

    public DataImportApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void dataImportMappingRuleChange() {
        feature("classpath:promin/data-import/FAT-1117.feature")
                .run();
    }

    @Test
    void dataImportModCopyCat() {
        feature("classpath:promin/data-import/mod-copycat.feature")
                .run();
    }

    @Test
    void dataImportTest() {
        feature("classpath:promin/data-import/features/")
                .threadCount(3)
                .run();
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            feature("classpath:promin/data-import/data-import-junit.feature")
                    .reportDir(timestampedReportDir())
                    .run();
        }
        feature("classpath:promin/data-import/global/create-marc-records.feature")
                .reportDir(timestampedReportDir())
                .run();
    }

    @AfterAll
    public void teardown() {
        if (shouldCreateTenant()) {
            try {
                feature("classpath:common/eureka/destroy-data.feature")
                        .reportDir(timestampedReportDir())
                        .run();
            } finally {
                System.clearProperty(TEST_TENANT.getValue());
                System.clearProperty(TEST_TENANT_ID.getValue());
            }
        }
    }
}
