package org.folio;

import org.apache.commons.lang.math.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import java.util.UUID;


@FolioTest(team = "firebird", module = "mod-oai-pmh")
public class ModOaiPmhTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/oaipmh/";

    public ModOaiPmhTests() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeEach
    public void setup() {
        System.setProperty("testTenant", "testoaipmh" + RandomUtils.nextLong());
        System.setProperty("testTenantId", UUID.randomUUID().toString());
        runFeature("classpath:firebird/mod-oai-pmh-junit.feature");
    }

    @AfterEach
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    void quickExportTest() {
        runFeatureTest("oaipmh-enhancement");
    }

    @Test
    void oaiPmhListRecordsAdditionalTests() {
        runFeatureTest("oaipmh-listRecords-additional");
    }

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

    @Test
    void oaiPmhSetsTests() {
        runFeatureTest("sets");
    }

    @Test
    void loadDefaultConfigurationTests() {
        runFeature("classpath:firebird/mod-configuration/load-default-pmh-configuration.feature");
    }
}
