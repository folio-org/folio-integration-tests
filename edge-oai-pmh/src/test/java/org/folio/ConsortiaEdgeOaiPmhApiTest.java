package org.folio;

import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "edge-oai-omh")
public class ConsortiaEdgeOaiPmhApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/consortia/";

    public ConsortiaEdgeOaiPmhApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature(TEST_BASE_PATH + "consortia-edge-oai-pmh-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature(TEST_BASE_PATH + "destroy-consortia.feature");
    }

    @Test
    public void test1() {
        runFeatureTest("features/deleted-marc-instances-C729197.feature");
    }

    @Test
    public void test2() {
        runFeatureTest("features/deleted-folio-instances-C729202.feature");
    }


    @Override
    public void runHook() {
        super.runHook();
        System.setProperty("consortiaAdminUserId", UUID.randomUUID().toString());
        System.setProperty("centralUserId", UUID.randomUUID().toString());
        System.setProperty("universityUserId", UUID.randomUUID().toString());
        System.setProperty("collegeUserId", UUID.randomUUID().toString());
        System.setProperty("consortiumId", UUID.randomUUID().toString());

        System.setProperty("randomNumbers", String.valueOf(ThreadLocalRandom.current().nextLong(Long.MAX_VALUE)));

        System.setProperty("centralTenantId", UUID.randomUUID().toString());
        System.setProperty("collegeTenantId", UUID.randomUUID().toString());
        System.setProperty("universityTenantId", UUID.randomUUID().toString());
    }
}
