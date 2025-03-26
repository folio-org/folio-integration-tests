package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "folijet", module = "mod-di-converter-storage")
@Disabled("REMOVE AFTER THE TESTS")
public class ModDataImportConverterStorageEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:folijet/mod-di-converter-storage/eureka-features/";

    public ModDataImportConverterStorageEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:folijet/mod-di-converter-storage/data-import-converter-storage-junit-eureka.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    void jobProfilesTest() {
        runFeatureTest("jobProfiles.feature");
    }

    @Test
    void createJobProfileTest() {
        runFeatureTest("create-profiles-and-remove-them.feature");
    }

    @Test
    void fieldProtectionTest() {
        runFeatureTest("field-protection.feature");
    }
}
