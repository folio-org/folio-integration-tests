package org.folio;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ModPasswordValidatorApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:domain/passwordvalidator/features/";

    public ModPasswordValidatorApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void modDataExportTestsBeforeAll() {
        runFeature("classpath:domain/passwordvalidator/basic-junit.feature");
    }

    @Test
    void quickExportTest() {
        runFeatureTest("rules");
    }

    @AfterAll
    public void ordersApiTestAfterAll() {
        runFeature("classpath:common/destroy-data.feature");
    }
}
