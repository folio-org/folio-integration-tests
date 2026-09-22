package org.folio;

import static org.folio.test.config.TestParam.TEST_TENANT;
import static org.folio.test.config.TestParam.TEST_TENANT_ID;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "promin", module = "mod-inventory")
class ModInventoryExtendedTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:promin/mod-inventory/features/";

    public ModInventoryExtendedTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
    }

    @BeforeAll
    public void setup() {
        if (shouldCreateTenant()) {
            runFeature("classpath:promin/mod-inventory/inventory-junit.feature");
        }
    }

    @AfterAll
    public void tearDown() {
        if (shouldCreateTenant()) {
            try {
                runFeature("classpath:common/eureka/destroy-data.feature");
            } finally {
                System.clearProperty(TEST_TENANT.getValue());
                System.clearProperty(TEST_TENANT_ID.getValue());
            }
        }
    }

    @Test
    void setForDeletion() {
        runFeatureTest("setForDeletion.feature");
    }

    @Test
    void updateHoldings() {
        runFeatureTest("inventory-update-holdings.feature");
    }
}
