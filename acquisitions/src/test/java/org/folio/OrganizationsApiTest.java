package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-organizations")
public class OrganizationsApiTest extends TestBase {

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-organizations/features/";

    public OrganizationsApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void organizationsApiTestBeforeAll() {
        runFeature("classpath:thunderjet/mod-organizations/organizations-junit.feature");
    }

    // Feature(s) list :
    @Test
    public void acquisitionsApiTestsFeature() {
        runFeature("classpath:thunderjet/mod-organizations/organizations.feature");
    }
}
