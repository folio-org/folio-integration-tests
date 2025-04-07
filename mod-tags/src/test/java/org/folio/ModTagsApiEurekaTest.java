package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
@Disabled
@FolioTest(team = "volaris", module = "tags")
class ModTagsApiEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:spitfire/tags/eureka-features/";

    public ModTagsApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modTagsBeforeAll() {
        runFeature("classpath:spitfire/tags/basic-junit-eureka.feature");
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
