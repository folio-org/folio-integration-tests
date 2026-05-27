package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "edge-oai-omh")
public class EdgeOaiPmhCriticalPathApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/";

    public EdgeOaiPmhCriticalPathApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
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
    public void test05() {
        runFeatureTest("ld-instance-add-holdings-C667569.feature");
    }

    @Test
    public void test06() {
        runFeatureTest("ld-instance-delete-holdings-C667577.feature");
    }

    @Test
    public void test07() {
        runFeatureTest("ld-instance-add-item-C667572.feature");
    }

    @Test
    public void test08() {
        runFeatureTest("ld-instance-edit-item-C667575.feature");
    }

    @Test
    public void test09() {
        runFeatureTest("ld-instance-delete-item-C667576.feature");
    }

    @Test
    public void test10() {
        runFeatureTest("ld-instance-edit-holdings-C667574.feature");
    }
}
