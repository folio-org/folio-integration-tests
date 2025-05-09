package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "folijet", module = "mod-copycat")
@Disabled("Migrated to Eureka")
public class ModCopycatTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:folijet/mod-copycat/features/";

    public ModCopycatTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:folijet/mod-copycat/copycat-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void getMappingRulesTest() {
        runFeatureTest("copycat-profiles.feature");
    }

}
