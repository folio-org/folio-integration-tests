package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ModCodexEkbApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:domain/codexekb/features/";

    public ModCodexEkbApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modCodexEkbBeforeAll() {
        runFeature("classpath:domain/codexekb/basic-junit.feature");
    }

    @Test
    void instancesTest() {
        runFeatureTest("codex-instances");
    }

    @AfterAll
    public void modCodexEkbAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
