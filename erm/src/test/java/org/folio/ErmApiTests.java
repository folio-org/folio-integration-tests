package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInfo;

import java.util.Set;

@FolioTest(team = "thunderjet", module = "erm")
public class ErmApiTests extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:thunderjet/erm/features/";
    private static final String SETUP_CREDENTIALS_TAG = "CREDENTIALS";

    public ErmApiTests() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup(TestInfo testInfo) {
        runFeature("classpath:thunderjet/erm/erm-junit.feature", testInfo);
    }

    @AfterAll
    public void tearDown(TestInfo testInfo) {
        runFeature("classpath:common/eureka/destroy-data.feature", testInfo);
    }

    @BeforeEach
    public void setupData(TestInfo testInfo) {
        Set<String> tags = testInfo.getTags();
        if (tags.contains(SETUP_CREDENTIALS_TAG)) {
            runFeature(TEST_BASE_PATH + "setup/setup-credentials.feature", testInfo);
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
    @DisplayName("(Thunderjet) (C1348606) Populate ResourceName For External eHoldings Agreement Lines")
    void populateResourceNameTest(TestInfo testInfo) {
        runFeatureTest("populate-resource-name", testInfo);
    }
}
