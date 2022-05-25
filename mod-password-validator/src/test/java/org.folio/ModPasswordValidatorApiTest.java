package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "password-validator")
public class ModPasswordValidatorApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:spitfire/passwordvalidator/features/";

    public ModPasswordValidatorApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modPasswordValidatorBeforeAll() {
        runFeature("classpath:spitfire/passwordvalidator/basic-junit.feature");
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
        runFeature("classpath:common/destroy-data.feature");
    }
}
