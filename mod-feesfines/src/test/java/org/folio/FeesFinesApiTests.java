package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "mod-feesfines")
class FeesFinesApiTests extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:vega/mod-feesfines/features/";

    public FeesFinesApiTests() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:vega/mod-feesfines/feesfines-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    void ownersTest() {
        runFeatureTest("owners");
    }

    @Test
    void accountsTest() {
        runFeatureTest("accounts");
    }

    @Test
    void feeFineActionsTest() {
        runFeatureTest("feeFineActions");
    }

    @Test
    void feeFineReportsTest() {
        runFeatureTest("feeFineReports");
    }

    @Test
    void feeFineTypesTest() {
        runFeatureTest("feeFineTypes");
    }

    @Test
    void lostItemFeePoliciesTest() {
        runFeatureTest("lostItemFeePolicies");
    }

    @Test
    void manualBlocksTest() {
        runFeatureTest("manualBlocks");
    }

    @Test
    void manualBlockTemplatesTest() {
        runFeatureTest("manualBlockTemplates");
    }

    @Test
    void overdueFinePoliciesTest() {
        runFeatureTest("overdueFinePolicies");
    }

    @Test
    void manualFeeFinesTest() {
        runFeatureTest("manualFeeFines");
    }

    @Test
    void automateFeeFinesTest() {
        runFeatureTest("automateFeeFines");
    }

    @Test
    void actualCostFeeFine() {
        runFeatureTest("actualCostFeeFine");
    }
}
