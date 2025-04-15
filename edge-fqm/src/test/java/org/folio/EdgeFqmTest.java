package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "corsair", module = "edge-fqm")
@Disabled
public class EdgeFqmTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:corsair/edge-fqm/features/";

    public EdgeFqmTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:corsair/edge-fqm/edge-fqm-junit.feature");
    }

    @Test
    void entityTypesTest() {
        runFeatureTest("edge-entity-types");
    }

    @Test
    void queryTest() {
        runFeatureTest("edge-query");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}
