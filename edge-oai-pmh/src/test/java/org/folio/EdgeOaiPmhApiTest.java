package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "edge-oai-omh")
public class EdgeOaiPmhApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/";

    public EdgeOaiPmhApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/edge-oai-pmh/edge-oai-pmh-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    public void test() {
        runFeatureTest("edge-oai-pmh.feature");
    }

    @Test
    public void InstanceSuppressedRecordsC163912Test() {
        runFeatureTest("instance-suppressed-records-C163912.feature");
    }

    @Test
    public void InstanceHoldingsSuppressedRecordsC193958Test() {
        runFeatureTest("instance-holdings-suppressed-records-C193958.feature");
    }

    @Test
    public void InstanceHoldingsItemsSuppressedRecordsC193959Test() {
        runFeatureTest("instance-holdings-items-suppressed-records-C193959.feature");
    }

    @Test
    public void InstanceSuppressedWithDiscoveryFlagC193960Test() {
        runFeatureTest("instance-suppressed-with-discovery-flag-C193960.feature");
    }

    @Test
    public void HoldingsItemsSuppressedWithDiscoveryFlagC193961C193961Test() {
        runFeatureTest("holdings-items-suppressed-with-discovery-flag-C193961.feature");
    }
}
