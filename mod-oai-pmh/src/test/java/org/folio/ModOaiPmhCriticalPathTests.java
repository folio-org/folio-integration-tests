package org.folio;

import java.util.UUID;
import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;


@FolioTest(team = "firebird", module = "mod-oai-pmh")
public class ModOaiPmhCriticalPathTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/oaipmh/";

    public ModOaiPmhCriticalPathTests() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
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

    @Test
    void oaiPmhGetRecordMarcDeletedSrsTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729189");
    }

    @Test
    void oaiPmhGetRecordMarcDeletedSrsInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729193");
    }

    @Test
    void oaiPmhGetRecordFolioDeletedInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729198");
    }

    @Test
    void oaiPmhGetRecordFolioDeletedSrsInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-C729199");
    }

    @Test
    void oaiPmhListIdentifiersDeletedC729195() {
        runFeatureTest("oaipmh-listidentifiers-deleted-C729195");
    }

    @Test
    void oaiPmhListIdentifiersDeletedC729201() {
        runFeatureTest("oaipmh-listidentifiers-deleted-C729201");
    }

    @Test
    void oaiPmhListRecordsC375976() {
        runFeatureTest("oaiPmhListRecordsC375976");
    }

    @Test
    void oaiPmhListRecordsC375978() {
        runFeatureTest("oaiPmhListRecordsC375978");
    }

    @Test
    void oaiPmhListRecordsC729194() {
        runFeatureTest("oaiPmhListRecordsC729194");
    }

    @Test
    void oaiPmhListRecordsC729200() {
        runFeatureTest("oaiPmhListRecordsC729200");
    }

    @Test
    void oaiPmhListRecordsC378101() {
        runFeatureTest("oaiPmhListRecordsC378101");
    }

    @Test
    void oaiPmhListRecordsC380606() {
        runFeatureTest("oaiPmhListRecordsC380606");
    }

    @Test
    void oaiPmhListRecordsC397334() {
        runFeatureTest("oaiPmhListRecordsC397334");
    }

    @Test
    void oaiPmhListRecordsAdditionalTestsWhenSourceIsInventory() {
        runFeatureTest("oaipmh-listRecords-sourceInventory");
    }

    @Test
    void oaiPmhListRecordsC163912() {
        runFeatureTest("oaiPmhListRecordsC163912");
    }
}
