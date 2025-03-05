package org.folio.eureka;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-data-export-spring")
@Disabled
public class DataExportSpringApiEurekaTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-data-export-spring/features/";

    public DataExportSpringApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:thunderjet/mod-data-export-spring/data-export-spring-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void rootTest() {
        runFeatureTest("root");
    }
}
