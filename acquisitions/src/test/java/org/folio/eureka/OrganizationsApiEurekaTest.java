package org.folio.eureka;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-organizations")
public class OrganizationsApiEurekaTest extends TestBaseEureka {

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-organizations/eureka/features/";

    public OrganizationsApiEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void organizationsApiTestBeforeAll() {
        System.setProperty("testTenant", "testorganizations" + RandomUtils.nextLong());
        System.setProperty("testTenantId", UUID.randomUUID().toString());
        runFeature("classpath:thunderjet/mod-organizations/eureka/organizations-junit.feature");
    }

    @AfterAll
    public void organizationsApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    // Feature(s) list :
    @Test
    void acquisitionsApiTests() {
        runFeatureTest("acquisitions-api-tests");
    }

    @Test
    void auditEventOrganization() {
        runFeatureTest("audit-event-organization");
    }

}
