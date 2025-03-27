package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "password-validator")
@Disabled("REMOVE AFTER THE TESTS")
public class ModPasswordValidatorApiEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:spitfire/passwordvalidator/eureka-features/";

    public ModPasswordValidatorApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modPasswordValidatorBeforeAll() {
        runFeature("classpath:spitfire/passwordvalidator/basic-junit-eureka.feature");
    }

    @Test
    void rulesTest() {
        runFeatureTest("rules");
    }

    @Test
    void validateTest() {
        runFeatureTest("validate");
    }

    @AfterAll
    public void modPasswordValidatorAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}