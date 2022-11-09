package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

@FolioTest(team = "spitfire", module = "mod-search")
class SearchApiTest extends TestBase {

    private static final String TEST_BASE_PATH = "classpath:spitfire/mod-search/";

    public SearchApiTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    void setUpTenant() {
        runFeatureTest("set-up/tenant-init");
    }

    @AfterAll
    void destroyTenant() {
        runFeatureTest("set-up/tenant-destroy");
    }

    @Test
    @Tag("search")
    void authoritySinglePropertySearchTest() {
        runFeatureTest("search/authority-single-property-search");
    }

    @Test
    @Tag("search")
    void singlePropertySearchTest() {
      runFeatureTest("search/single-property-search");
    }

    @Test
    @Tag("search")
    void resourceJobIdsSearchTest() {
        runFeatureTest("search/resource-job-ids-search");
    }

    @Test
    @Tag("search")
    void booleanSearchTest() {
      runFeatureTest("search/boolean-search");
    }

    @Test
    @Tag("filters")
    void filterSearchTest() {
      runFeatureTest("filters/filter-search.feature");
    }

    @Test
    @Tag("filters")
    void facetSearchTest() {
      runFeatureTest("filters/facet-search.feature");
    }

    @Test
    @Tag("filters")
    void sortingSearchTest() {
      runFeatureTest("filters/sort-by-option-search.feature");
    }

    @Test
    @Tag("browse")
    void authorityBrowseTest() {
      runFeatureTest("browse/authority-browse.feature");
    }

    @Test
    @Tag("browse")
    void callNumberBrowseTest() {
      runFeatureTest("browse/call-number-browse.feature");
    }

    @Test
    @Tag("browse")
    void subjectBrowseTest() {
      runFeatureTest("browse/subject-browse.feature");
    }

    @Test
    @Tag("browse")
    void contributorBrowseTest() {
      runFeatureTest("browse/contributor-browse.feature");
    }
}
