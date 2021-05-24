package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class SearchApiTest extends TestBase {

    public SearchApiTest() {
        super(new TestIntegrationService(new TestModuleConfiguration("classpath:domain/search/")));
    }

    @BeforeAll
    void setUpTestData() {
        runFeature("classpath:domain/search/init/create-test-data.feature");
    }

    @AfterAll
    void removeTestData() {
        runFeature("classpath:domain/search/init/remove-test-data.feature");
    }

    @Test
    void runSearchTest() {
        runFeature("classpath:domain/search/search.feature");
    }
}
