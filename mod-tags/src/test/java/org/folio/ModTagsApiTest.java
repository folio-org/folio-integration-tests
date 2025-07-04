package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "tags")
class ModTagsApiTest extends TestBaseEureka {
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
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}
