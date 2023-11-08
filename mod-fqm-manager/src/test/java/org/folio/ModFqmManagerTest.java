package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "corsair", module = "mod-fqm-manager")
public class ModFqmManagerTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:corsair/mod-fqm-manager/features/";

    public ModFqmManagerTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:corsair/mod-fqm-manager/fqm-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void entityTypesTest() {
        runFeatureTest("entity-types");
    }

    @Test
    void queryTest() {
        runFeatureTest("query");
    }
}
