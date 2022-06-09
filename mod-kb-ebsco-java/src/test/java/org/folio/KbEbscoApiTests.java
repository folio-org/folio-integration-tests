package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.*;

@FolioTest(team = "spitfire", module = "mod-kb-ebsco-java")
class KbEbscoApiTests extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-kb-ebsco-java/features/";
    private static final String SETUP_CREDENTIALS_TAG = "CREDENTIALS";
    
    public KbEbscoApiTests() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:spitfire/mod-kb-ebsco-java/kb-ebsco-junit.feature");
    }

    @BeforeEach
    public void setupCredentials(TestInfo testInfo) {
        if (testInfo.getTags().contains(SETUP_CREDENTIALS_TAG)) {
            runFeature("classpath:spitfire/mod-kb-ebsco-java/features/setup/setup.feature", testInfo);
        }
    }

    @AfterAll
    public void tearDown(TestInfo testInfo) {
        runFeature("classpath:common/destroy-data.feature", testInfo);
    }

    @AfterEach
    public void destroyCredentials(TestInfo testInfo) {
        if (testInfo.getTags().contains(SETUP_CREDENTIALS_TAG)) {
            runFeature("classpath:spitfire/mod-kb-ebsco-java/features/setup/destroy.feature", testInfo);
        }
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void accessTypesTest(TestInfo testInfo) {
        runFeatureTest("access-types", testInfo);
    }

    @Test
    void kbCredentialsTest(TestInfo testInfo) {
        runFeatureTest("kb-credentials", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void packagesTest(TestInfo testInfo) {
        runFeatureTest("packages", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void providersTest(TestInfo testInfo) {
        runFeatureTest("providers", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void proxyTest(TestInfo testInfo) {
        runFeatureTest("proxy", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void resourcesTest(TestInfo testInfo) {
        runFeatureTest("resources", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void statusTest(TestInfo testInfo) {
        runFeatureTest("status", testInfo);
    }

    @Test
    void tagsTest(TestInfo testInfo) {
        runFeatureTest("tags", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void titlesTest(TestInfo testInfo) {
        runFeatureTest("titles", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void userAssigmentTest(TestInfo testInfo) {
        runFeatureTest("user-assignment", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void usageConsolidationTest(TestInfo testInfo) {
        runFeatureTest("usage-consolidation", testInfo);
    }
}
