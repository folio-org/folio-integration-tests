package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class SearchApiTest extends TestBase {
    SearchApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration("classpath:domain/")));
    }

    @BeforeAll
    void setUpTenant() {
        runFeature("classpath:set-up/tenant-init.feature");
    }

    @AfterAll
    void destroyTenant() {
        runFeature("classpath:set-up/tenant-destroy.feature");
    }

    @ValueSource(strings = {
            "single-property-search",
            "boolean-search"
    })
    @ParameterizedTest
    void runSearchTest(String featureName) {
        runFeatureTest("search/" + featureName);
    }

    @ValueSource(strings = {
            "facet-search.feature",
            "filter-search"
    })
    @ParameterizedTest
    void runFiltersTest(String featureName) {
        runFeatureTest("filters/" + featureName);
    }
}
