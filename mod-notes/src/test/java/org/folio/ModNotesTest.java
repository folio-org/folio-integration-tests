package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "mod-notes")
@Disabled("Migrated to Eureka")
class ModNotesTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-notes/features/";

    public ModNotesTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:spitfire/mod-notes/notes-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    void notesTest() {
        runFeatureTest("notes.feature");
    }

    @Test
    void noteTypesTest() {
        runFeatureTest("note-types.feature");
    }

    @Test
    void noteLinksTest() {
        runFeatureTest("note-links.feature");
    }
}
