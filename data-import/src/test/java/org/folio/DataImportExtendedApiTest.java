package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.*;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

@FolioTest(team = "folijet", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataImportExtendedApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:folijet/data-import/features/";

    public DataImportExtendedApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
    }

    @Test
    void fat21038Contributors() {
        feature("classpath:folijet/data-import/features/marc-records/marc-bibs/create/FAT-21038.feature")
                .run();
    }

    @Test
    void diAuthorityExtended() {
        feature("classpath:folijet/data-import/features/marc-records/data-import-authority-records-extended.feature")
                .run();
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            feature("classpath:folijet/data-import/data-import-junit.feature")
                    .reportDir(timestampedReportDir())
                    .run();
        }
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
