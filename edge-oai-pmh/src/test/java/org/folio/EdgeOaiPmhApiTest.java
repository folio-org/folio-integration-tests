package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.Optional;

@FolioTest(team = "firebird", module = "edge-oai-omh")
public class EdgeOaiPmhApiTest extends TestBase {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/";

    public EdgeOaiPmhApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runHook();
        runFeature("classpath:firebird/edge-oai-pmh/edge-oai-pmh-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature("classpath:common/destroy-data.feature");
    }

    @Test
    public void testMarc21WithHoldingsListRecords() {
        runFeatureTest("marc21_withholdings_list_records.feature");
    }

    @Override
    public void runHook() {
        Optional.ofNullable(System.getenv("karate.env"))
                .ifPresent(env -> System.setProperty("karate.env", env));
        System.setProperty("testTenant", "testoaipmh");
    }
}
