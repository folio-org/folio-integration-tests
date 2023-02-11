package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "folijet", module = "mod-di-converter-storage")
public class ModDataImportConverterStorageTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:folijet/mod-di-converter-storage/features/";

    public ModDataImportConverterStorageTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:folijet/mod-di-converter-storage/data-import-converter-storage-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void jobProfilesTest() {
        runFeatureTest("jobProfiles");
    }

    @Test
    void createJobProfileTest() {
        runFeatureTest("create-profiles-and-remove-them");
    }

    @Test
    void fieldProtectionTest() {
        runFeatureTest("field-protection");
    }
}
