package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.List;
import java.util.stream.Stream;

@FolioTest(team = "corsair", module = "mod-fqm-manager")
public class ModFqmManagerEurekaTest extends TestBaseEureka {

    private static final String TEST_BASE_PATH = "classpath:corsair/mod-fqm-manager/eureka-features/";

    public ModFqmManagerEurekaTest() {
        super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature("classpath:corsair/mod-fqm-manager/fqm-junit-eureka.feature");
    }

//    @AfterAll
//    public void tearDown() {
//        runFeature("classpath:common/eureka/destroy-data.feature");
//    }

    static List<Arguments> features() {
        return Stream
                .of(
                        "entity-types"
//                        "migration",
//                        "query/basic-usage",
//                        "query/operators-basic",
//                        "query/operators-array",
//                        "query/per-entity-type",
//                        "query/special-field-tests",
//                        "query/validation"
                )
                .map(Arguments::of)
                .toList();
    }

    @ParameterizedTest
    @MethodSource("features")
    void featureTest(String feature) {
//        runFeatureTest(feature);
    }
}
