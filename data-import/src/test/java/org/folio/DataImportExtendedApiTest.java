package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.*;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

@FolioTest(team = "promin", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataImportExtendedApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";

    public DataImportExtendedApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
    }

    @Test
    void fat21038Contributors() {
        feature("classpath:promin/data-import/features/marc-records/marc-bibs/create/FAT-21038.feature")
                .run();
    }

    @Test
    void fat21039Contributors() {
        feature("classpath:promin/data-import/features/marc-records/marc-bibs/create/FAT-21039.feature")
                .run();
    }

    private static final String DELETE_AUTHORITY_PATH =
            "classpath:promin/data-import/features/marc-records/marc-authorities/delete/";

    // FAT-26991: Delete MARC Authority with match by 001, 010 $a, 999 ff $i, 999 ff $s
    // TODO: add TestRail case ids to the scenarios once the cases exist

    @Test
    void deleteAuthorityMatchBy001() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-match-001.feature")
                .run();
    }

    @Test
    void deleteAuthorityMatchBy010a() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-match-010a.feature")
                .run();
    }

    @Test
    void deleteAuthorityMatchBy999ffi() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-match-999ffi.feature")
                .run();
    }

    @Test
    void deleteAuthorityMatchBy999ffs() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-match-999ffs.feature")
                .run();
    }

    @Test
    void diAuthorityExtended() {
        feature("classpath:promin/data-import/features/marc-records/data-import-authority-records-extended.feature")
                .run();
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            feature("classpath:promin/data-import/data-import-junit.feature")
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
