package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;

@FolioTest(team = "folijet", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataImportExtendedApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:folijet/data-import/features/";

    public DataImportExtendedApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void fat21038Contributors() {
        feature("classpath:folijet/data-import/features/marc-records/marc-bibs/create/FAT-21038.feature")
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
            feature("classpath:common/eureka/destroy-data.feature")
                    .reportDir(timestampedReportDir())
                    .run();
        }
    }

}
