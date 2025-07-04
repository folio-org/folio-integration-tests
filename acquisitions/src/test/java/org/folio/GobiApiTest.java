package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-gobi")
public class GobiApiTest extends TestBaseEureka {

    // Default module settings :
    private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-gobi/features/";

    public GobiApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void gobiApiTestBeforeAll() {
        System.setProperty("testTenant", "testmodgobi" + RandomUtils.nextLong());
        System.setProperty("testTenantId", UUID.randomUUID().toString());
        runFeature("classpath:thunderjet/mod-gobi/init-gobi.feature");
    }

    @AfterAll
    public void gobiApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }


    @Test
    void gobiApiTests() {
        runFeatureTest("gobi-api-tests");
    }

    @Test
    void findHoldingsByLocationAndInstance() {
        runFeatureTest("find-holdings-by-location-and-instance");
    }

    @Test
    void validatePoLineReceiptNotRequiredWithCheckinItems() {
        runFeatureTest("validate-pol-receipt-not-required-with-checkin-items");
    }

}
