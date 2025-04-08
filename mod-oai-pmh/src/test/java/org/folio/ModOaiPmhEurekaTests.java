package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;


@FolioTest(team = "firebird", module = "mod-oai-pmh")
public class ModOaiPmhEurekaTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/oaipmh/eureka/";

    public ModOaiPmhEurekaTests() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/mod-oai-pmh-junit-eureka.feature");
    }

    @AfterAll
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

    @Disabled("This feature file contains test cases for enabling and disabling modules. However, in the Eureka environment, we work with applications instead of modules, so the logic in this feature is not applicable.")
    @Test
    void loadDefaultConfigurationTests() {
        runFeature("classpath:firebird/mod-configuration/eureka/load-default-pmh-configuration.feature");
    }
}
