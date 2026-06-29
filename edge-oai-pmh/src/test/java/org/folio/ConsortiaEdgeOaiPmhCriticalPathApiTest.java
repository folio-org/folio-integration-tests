package org.folio;

import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "edge-oai-pmh")
public class ConsortiaEdgeOaiPmhCriticalPathApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/consortia/";

    public ConsortiaEdgeOaiPmhCriticalPathApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
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

    @Test
    public void test3() {
        runFeatureTest("features/linked-data-edited-item-C688762.feature");
    }

    @Test
    public void test4() {
        runFeatureTest("features/linked-data-edited-main-title-C688749.feature");
    }

    @Test
    public void test5() {
        runFeatureTest("features/linked-data-edited-holdings-C688755.feature");
    }

    @Test
    public void test6() {
        runFeatureTest("features/linked-data-add-item-C688761.feature");
    }

    @Test
    public void test7() {
        runFeatureTest("features/linked-data-add-holdings-C688752.feature");
    }

    @Test
    public void test8() {
        runFeatureTest("features/linked-data-get-record-edited-main-title-C667579.feature");
    }

    @Test
    public void test9() {
        runFeatureTest("features/shared-local-marc-suppressed-get-record-C468257.feature");
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
