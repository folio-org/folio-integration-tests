package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "mod-bulk-operations")

public class ModBulkOperationsApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/mod-bulk-operations/features/";

    public ModBulkOperationsApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/mod-bulk-operations/mod-bulk-operations-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    public void testUsers() {
        runFeatureTest("users.feature");
    }

    @Test
    public void testHoldings() {
        runFeatureTest("holdings.feature");
    }

    @Test
    public void testItems() {
        runFeatureTest("items.feature");
    }

    @Test
    public void testInstances() {
        runFeatureTest("instances.feature");
    }
}
