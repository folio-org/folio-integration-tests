package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "mod-entities-links")
@Disabled
class ModEntitiesLinksEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-entities-links/eureka-features/";

    public ModEntitiesLinksEurekaTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:spitfire/mod-entities-links/links-junit-eureka.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    void entitiesLinksTest() {
        runFeatureTest("entitiesLinksTest.feature");
    }

    @Test
    void linkingRulesTest() {
        runFeatureTest("linkingRulesTest.feature");
    }

    @Test
    void authoritiesFiltering() {
        runFeatureTest("get-authorities-with-filtering.feature");
    }


}
