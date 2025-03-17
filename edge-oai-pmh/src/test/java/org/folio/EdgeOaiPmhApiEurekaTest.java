package org.folio;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "firebird", module = "edge-oai-omh")
@Disabled("Until karate scenarios would be refactored")
@Deprecated
public class EdgeOaiPmhApiEurekaTest extends TestBaseEureka {
    private static final String TEST_BASE_PATH = "classpath:firebird/edge-oai-pmh/features/";

    public EdgeOaiPmhApiEurekaTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

//    @BeforeAll
//    public void setup() {
//        runFeature("classpath:firebird/edge-oai-pmh/edge-oai-pmh-junit-eureka.feature");
//    }

//    @AfterAll
//    public void tearDown() {
//        runFeature("classpath:common/destroy-data.feature");
//    }

    @Test
    public void test() {
        runFeatureTest("edge-oai-pmh.feature");
    }
}