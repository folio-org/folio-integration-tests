package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;

import java.util.UUID;


@FolioTest(team = "firebird", module = "mod-oai-pmh")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ModOaiPmhTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/oaipmh/";

    public ModOaiPmhTests() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        System.setProperty("testTenant", "testoaipmh" + RandomUtils.nextLong());
        System.setProperty("testTenantId", UUID.randomUUID().toString());
        runFeature("classpath:firebird/mod-oai-pmh-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Order(1)
    @Test
    void quickExportTest() {
        runFeatureTest("oaipmh-enhancement");
    }

    @Order(2)
    @Test
    void oaiPmhListRecordsAdditionalTests() {
        runFeatureTest("oaipmh-listRecords-additional");
    }

    @Order(3)
    @Test
    void oaiPmhListRecordsAdditionalTestsWhenSourceIsInventory() {
        runFeatureTest("oaipmh-listRecords-sourceInventory");
    }

    @Disabled("Disabled until the records retrieving within verbs like ListRecords and listIdentifiers " +
            "will be switched to use the inventory storage + generate marc utils on the fly library instead of SRS only")
    @Test
    void oaiPmhMarWithHoldingsTests() {
        runFeatureTest("oaipmh-q3-marc_withholdings");
    }

    @Order(4)
    @Test
    void oaiPmhSetsTests() {
        runFeatureTest("sets");
    }

    @Order(5)
    @Test
    void loadDefaultConfigurationTests() {
        runFeature("classpath:firebird/mod-configuration/load-default-pmh-configuration.feature");
    }

    @Order(6)
    @Test
    void oaiPmhGetRecordMarcDeletedSrsTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729189");
    }

    @Order(7)
    @Test
    void oaiPmhGetRecordMarcDeletedSrsInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729193");
    }

    @Order(8)
    @Test
    void oaiPmhGetRecordFolioDeletedInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729198");
    }

    @Order(9)
    @Test
    void oaiPmhGetRecordFolioDeletedSrsInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729199");
    }

    @Order(10)
    @Test
    void oaiPmhListIdentifiersDeletedC729195() {
        runFeatureTest("oaipmh-listidentifiers-deleted-C729195");
    }

    @Order(11)
    @Test
    void oaiPmhListIdentifiersDeletedC729201() {
        runFeatureTest("oaipmh-listidentifiers-deleted-C729201");
    }

//    @Order(12)
//    @Test
//    void oaiPmhListRecordsC375976() {
//        runFeatureTest("oaiPmhListRecordsC375976");
//    }
//
//    @Order(13)
//    @Test
//    void oaiPmhListRecordsC375978() {
//        runFeatureTest("oaiPmhListRecordsC375978");
//    }
//
//    @Order(14)
//    @Test
//    void oaiPmhListRecordsC729194() {
//        runFeatureTest("oaiPmhListRecordsC729194");
//    }
//
//    @Order(15)
//    @Test
//    void oaiPmhListRecordsC729200() {
//        runFeatureTest("oaiPmhListRecordsC729200");
//    }
}
