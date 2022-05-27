package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "bulk-edit")
public class ModBulkEditApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:firebird/bulk-edit/features/";

    public ModBulkEditApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    //TODO replace diku-bulk-edit-junit.feature with bulk-edit-junit.feature in scope of FAT-1645
    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/bulk-edit/diku-bulk-edit-junit.feature");
    }

    @Test
    public void bulkdEditUsersTest() {
        runFeatureTest("bulk-edit-users.feature");
    }

    @Test
    public void bulkdEditItemTest() {

        //TODO
    }

    //TODO uncomment @AfterAll in scope of FAT-1645
//    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    //TODO remove method overriding in scope of FAT-1645
    @Override
    public void runHook() {
        super.runHook();
        System.setProperty("testTenant", "supertenant");
        //do for local and snapshot
        //System.setProperty("testTenant", "diku");
    }
}