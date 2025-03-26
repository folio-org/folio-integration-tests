package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "corsair", module = "mod-lists")
public class ModListsEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH =
            "classpath:corsair/mod-lists/eureka-features/";

    public ModListsEurekaTest() {
        super(
                new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
        );
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:corsair/mod-lists/lists-junit-eureka.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/eureka/destroy-data.feature");
    }

    @Test
    void testGetLists() {
        runFeatureTest("get-lists");
    }

    @Test
    void testGetListContents() {
        runFeatureTest("get-list-contents");
    }

    @Test
    void testAccessControl() {
        runFeatureTest("access-control");
    }

    @Test
    void testCreate() {
        runFeatureTest("create");
    }

    @Test
    void testUpdate() {
        runFeatureTest("update");
    }

    @Test
    void testDelete() {
        runFeatureTest("delete");
    }

    @Test
    void testExport() {
        runFeatureTest("export");
    }

    @Test
    void testRefresh() {
        runFeatureTest("refresh");
    }

    @Test
    void testVersioning() {
        runFeatureTest("versions");
    }
}
