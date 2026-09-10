package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

/**
 * Data import scenarios that TestRail classifies as Critical Path.
 */
@FolioTest(team = "promin", module = "data-import")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataImportCriticalPathApiTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:promin/data-import/features/";
    private static final String DELETE_AUTHORITY_PATH =
            TEST_BASE_PATH + "marc-records/marc-authorities/delete/";

    public DataImportCriticalPathApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
    }

    // FAT-26991 / UXPROD-4627: delete MARC Authority records via data import.
    // C1434631, C1504469, C1504474, C1504476, C1504477, C1504478.

    @Test
    void deleteAuthorityDefaultJobProfile() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-default-job-profile.feature")
                .run();
    }

    @Test
    void deleteAuthorityDefaultJobProfileLinked() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-default-profile-linked.feature")
                .run();
    }

    @Test
    void deleteAuthorityJobSummaryStatuses() {
        feature(DELETE_AUTHORITY_PATH + "FAT-26991-delete-authority-job-summary-statuses.feature")
                .run();
    }

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
