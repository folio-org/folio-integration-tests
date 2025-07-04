package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "edge-inn-reach")
class EdgeInnReachApiTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:volaris/edge-inn-reach/features/";

    public EdgeInnReachApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    void testInnReachproxy() {
        runFeatureTest("inn-reach-proxy.feature");
    }

    @BeforeAll
    public void edgeInnReachApiTestBeforeAll() {
        runFeature("classpath:volaris/edge-inn-reach/edge-inn-reach-junit.feature");
    }

    @AfterAll
    public void edgeInnReachApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}
