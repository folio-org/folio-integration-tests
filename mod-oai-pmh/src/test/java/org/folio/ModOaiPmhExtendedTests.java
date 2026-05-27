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
public class ModOaiPmhExtendedTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/oaipmh/";

    public ModOaiPmhExtendedTests() {
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
        try {
            runFeature("classpath:common/eureka/destroy-data.feature");
        } finally {
            super.afterAll();
        }
    }

    @Test
    void oaiPmhGetRecordMarcDeletedBySrsLeaderSrsInvTests() {
        runFeatureTest("oaipmh-getrecord-deleted-srs-leader-past-C375977");
    }

    @Test
    void oaiPmhGetRecord856ComponentParts() {
        runFeatureTest("oaiPmhGetRecord856ComponentParts-C388528");
    }

    @Test
    void oaiPmhHoldingsIllPolicy() {
        runFeatureTest("oaiPmhHoldingsIllPolicy-C423498");
    }

    @Test
    void oaiPmhHoldingsIllPolicyInventory() {
        runFeatureTest("oaiPmhHoldingsIllPolicyInventory-C423535");
    }

    @Test
    void oaiPmhListRecords856SourceStorage() {
        runFeatureTest("oaiPmhListRecords856SourceStorage-C388516");
    }

    @Test
    void verifyBehaviorConfigurationC375138() {
        runFeatureTest("verifyBehaviorConfigurationC375138");
    }

    @Test
    void oaiPmhGetRecordDeletedItemsWithholdingsC375984() {
        runFeatureTest("oaipmh-getrecord-deleted-items-withholdings-C375984");
    }

    @Test
    void oaiPmhListRecordsDeletedEditedMarcFolio() {
        runFeatureTest("oaipmh-listrecords-deleted-edited-marc-folio-C926147");
    }
}
