package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class FeesFinesApiTests extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:domain/mod-feesfines/features/";

    public FeesFinesApiTests() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:domain/mod-feesfines/feesfines-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void owners() {
        runFeatureTest("owners.feature");
    }

    @Test
    void accounts() {
        runFeatureTest("accounts");
    }

    @Test
    void feeFineActions() {
        runFeatureTest("feeFineActions");
    }

    @Test
    void feeFineReports() {
        runFeatureTest("feeFineReports");
    }

    @Test
    void feeFineTypes() {
        runFeatureTest("feeFineTypes");
    }

    @Test
    void lostItemFeePolicies() {
        runFeatureTest("lostItemFeePolicies");
    }

    @Test
    void manualBlocks() {
        runFeatureTest("manualBlocks");
    }

    @Test
    void manualBlockTemplates() {
        runFeatureTest("manualBlockTemplates");
    }

    @Test
    void overdueFinePolicies() {
        runFeatureTest("overdueFinePolicies");
    }

    @Test
    void moduleTenantApi() {
        runFeatureTest("moduleTenantApi");
    }
}
