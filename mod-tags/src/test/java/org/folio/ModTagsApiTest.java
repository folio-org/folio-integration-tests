package org.folio;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;

class ModTagsApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:spitfire/tags/features/";

    public ModTagsApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modTagsBeforeAll() {
        runFeature("classpath:spitfire/tags/basic-junit.feature");
    }

    @Test
    void tagsTest() {
        runFeatureTest("tags");
    }

    @AfterAll
    public void modTagsAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
