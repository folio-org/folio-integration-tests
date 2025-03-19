package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;

@FolioTest(team = "spitfire", module = "mod-quick-marc")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Disabled("Until the issue with the tests is resolved")
class QuickMarcApiEurekaTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-quick-marc/eureka-features/";

    public QuickMarcApiEurekaTest() {
        super(new TestIntegrationService(
            new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @Test
    @Order(1)
    void testQuickMarcAuthorityRecordsFeature() {
        runFeatureTest("quick-marc-authority-records.feature");
    }

    @Test
    @Order(2)
    void testQuickMarcBibRecordsFeature() {
        runFeatureTest("quick-marc-bib-records.feature");
    }

    @Test
    @Order(3)
    void testQuickMarcHoldingsRecordsFeature() {
        runFeatureTest("quick-marc-holdings-records.feature");
    }

    @Test
    @Order(4)
    void testQuickMarcRecordStatusFeature() {
        runFeatureTest("quick-marc-record-status.feature");
    }

    @Test
    @Order(5)
    void testQuickMarcLinkingRecordsFeature() {
        runFeatureTest("quick-marc-linking-records.feature");
    }

    @BeforeAll
    public void quickMarcApiTestBeforeAll() {
        runFeature("classpath:spitfire/mod-quick-marc/quick-marc-junit-eureka.feature");
        runFeatureTest("setup/setup.feature");
    }

    @AfterAll
    public void quickMarcApiTestAfterAll() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }
}
