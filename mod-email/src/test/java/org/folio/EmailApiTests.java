package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class EmailApiTests extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:domain/mod-email/features/";

    public EmailApiTests() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:domain/mod-email/email-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void emailTest() {
        runFeatureTest("email");
    }

    @Test
    void delayedTest() {
        runFeatureTest("delayedTasks");
    }

    @Test
    void moduleTenantApiTest() {
        runFeatureTest("moduleTenantApi");
    }
}
