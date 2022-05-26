package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "bulk-edit")
public class ModBulkEditApiTestForItem extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:firebird/bulk-edit/features/";

    public ModBulkEditApiTestForItem() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }


    @BeforeAll
    public void setup() {
        runFeature("classpath:firebird/bulk-edit/diku-bulk-edit-junit-item.feature");
    }

    @Test
    public void bulkdEditItemTest() {

        System.out.println("TEST---");

        //runFeature test will be added TODO
    }


    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    //TODO remove method overriding in scope of FAT-1645
    @Override
    public void runHook() {
        super.runHook();
        //System.setProperty("testTenant", "supertenant");
        //for local testing
        //System.setProperty("testTenant", "diku");
    }
}