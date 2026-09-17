package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@FolioTest(team = "athena", module = "mod-lists")
public class ModListsTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH =
            "classpath:athena/mod-lists/features/";

    public ModListsTest() {
        super(
                new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH))
        );
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:athena/mod-lists/lists-junit.feature");
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
    void testStatisticalCodes() {
        runFeatureTest("statistical-codes");
    }

    @Test
    void testVersioning() {
        runFeatureTest("versions");
    }

    @Test
    @DisplayName("(C1348599) Agreements + Lines ET Displays Agreement And Line Records")
    void testAgreementLinesEntityType() {
        runFeatureTest("agreement-lines-entity-type");
    }

    @Test
    @DisplayName("(C1373047) Agreements - Invoices - Orders ET Displays Agreement, Lines, PO Lines And Invoice Lines")
    void testAgreementsInvoicesOrdersEntityType() {
        runFeatureTest("agreements-invoices-orders-entity-type");
    }

    @Test
    void testEcsExport() {
        runFeatureTest("consortia/consortia-list");
    }
}
