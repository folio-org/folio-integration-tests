package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "bulk-edit")
public class ModBulkEditApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:firebird/bulk-edit/features/";

    public ModBulkEditApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/bulk-edit/bulk-edit-junit.feature");
    }

    @Test
    public void bulkdEditUsersTest() {
        runFeatureTest("bulk-edit-users.feature");
    }

//    @Test
    public void bulkdEditItemTest() {
        runFeatureTest("bulk-edit-items.feature");
    }

//    @Test
    public void bulkdEditItemStatusTest() {
        runFeatureTest("bulk-edit-items-status.feature");
    }

//    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }
}