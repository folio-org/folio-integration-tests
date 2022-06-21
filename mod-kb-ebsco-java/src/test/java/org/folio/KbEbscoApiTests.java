package org.folio;

import java.util.Set;
import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInfo;

@FolioTest(team = "spitfire", module = "mod-kb-ebsco-java")
class KbEbscoApiTests extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-kb-ebsco-java/features/";
    private static final String SETUP_CREDENTIALS_TAG = "CREDENTIALS";
    private static final String SETUP_RESOURCES_TAG = "RESOURCES";

    public KbEbscoApiTests() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup(TestInfo testInfo) {
        runFeature("classpath:spitfire/mod-kb-ebsco-java/kb-ebsco-junit.feature", testInfo);
    }

    @AfterAll
    public void tearDown(TestInfo testInfo) {
        runFeature("classpath:common/destroy-data.feature", testInfo);
    }

    @BeforeEach
    public void setupData(TestInfo testInfo) {
        Set<String> tags = testInfo.getTags();
        if (tags.contains(SETUP_CREDENTIALS_TAG)) {
            runFeature(TEST_BASE_PATH + "setup/setup-credentials.feature", testInfo);
        }
        if (tags.contains(SETUP_RESOURCES_TAG)) {
            runFeature(TEST_BASE_PATH + "setup/setup-resources.feature", testInfo);
        }
    }

    @AfterEach
    public void destroyCredentials(TestInfo testInfo) {
        if (testInfo.getTags().contains(SETUP_CREDENTIALS_TAG)) {
            runFeature(TEST_BASE_PATH + "setup/destroy.feature", testInfo);
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
    @Tag(SETUP_RESOURCES_TAG)
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
    @Tag(SETUP_RESOURCES_TAG)
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
    @Tag(SETUP_RESOURCES_TAG)
    @Tag(SETUP_CREDENTIALS_TAG)
    void titlesTest(TestInfo testInfo) {
        runFeatureTest("titles", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void userAssignmentTest(TestInfo testInfo) {
        runFeatureTest("user-assignment", testInfo);
    }

    @Test
    @Tag(SETUP_CREDENTIALS_TAG)
    void usageConsolidationTest(TestInfo testInfo) {
        runFeatureTest("usage-consolidation", testInfo);
    }

    @Test
    @Tag(SETUP_RESOURCES_TAG)
    @Tag(SETUP_CREDENTIALS_TAG)
    void exportTest(TestInfo testInfo) {
        runFeatureTest("export-for-e-holdings", testInfo);
    }
}
