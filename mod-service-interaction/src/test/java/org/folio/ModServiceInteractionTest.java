package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

/**
 * API integration tests for mod-service-interaction.
 *
 * <p>The corpus is authored against the legacy Grails module (repository
 * master) and runs unchanged against the Spring Boot port, so both can be
 * exercised with the same suite and compared for functional parity and data
 * integrity. Select the deployment with {@code -Dkarate.env=legacy|port}
 * (default {@code legacy}); see the module README for the environment
 * contract.
 *
 * <p>Unlike the gateway-backed suites in this repository, the tenant is
 * provisioned by calling the module's own {@code /_/tenant} interface and the
 * acting user is carried in {@code X-Okapi-User-Id} — the module derives every
 * identity and authority from the Okapi headers, so no login, mod-users or
 * keycloak bootstrap is required. That keeps the two implementations
 * comparable in an isolated environment.
 */
@FolioTest(team = "bienenvolk", module = "mod-service-interaction")
class ModServiceInteractionTest extends TestBaseEureka {

    private static final String BASE_PATH = "classpath:bienenvolk/mod-service-interaction/";
    private static final String TEST_BASE_PATH = BASE_PATH + "features/";

    public ModServiceInteractionTest() {
        super(new TestIntegrationService(
                new TestModuleConfiguration(TEST_BASE_PATH)));
    }

    @BeforeAll
    public void setup() {
        runFeature(BASE_PATH + "servint-junit.feature");
    }

    @AfterAll
    public void tearDown() {
        runFeature(BASE_PATH + "servint-teardown.feature");
    }

    // ------------------------------------------------------- tenant surface

    @Test
    void tenantLifecycleTest() {
        runFeatureTest("tenant-lifecycle.feature");
    }

    @Test
    void referenceDataSeedingTest() {
        runFeatureTest("reference-data-seeding.feature");
    }

    // ------------------------------------------- reference data and settings

    @Test
    void refdataTest() {
        runFeatureTest("refdata.feature");
    }

    @Test
    void appSettingsTest() {
        runFeatureTest("app-settings.feature");
    }

    // ------------------------------------------------------ number generators

    @Test
    void numgenManagementTest() {
        runFeatureTest("numgen-management.feature");
    }

    @Test
    void numberGenerationTest() {
        runFeatureTest("number-generation.feature");
    }

    @Test
    void numgenLimitsTest() {
        runFeatureTest("numgen-limits.feature");
    }

    @Test
    void numgenYearResetTest() {
        runFeatureTest("numgen-year-reset.feature");
    }

    // ------------------------------------------------------------ dashboards

    @Test
    void dashboardManagementTest() {
        runFeatureTest("dashboard-management.feature");
    }

    @Test
    void dashboardAccessTest() {
        runFeatureTest("dashboard-access.feature");
    }

    @Test
    void dashboardUserManagementTest() {
        runFeatureTest("dashboard-user-management.feature");
    }

    @Test
    void dashboardUserOrderingTest() {
        runFeatureTest("dashboard-user-ordering.feature");
    }

    @Test
    void dashboardDisplayDataTest() {
        runFeatureTest("dashboard-display-data.feature");
    }

    // --------------------------------------------------------------- widgets

    @Test
    void widgetTypesAndDefinitionsTest() {
        runFeatureTest("widget-types-definitions.feature");
    }

    @Test
    void widgetInstancesTest() {
        runFeatureTest("widget-instances.feature");
    }

    // ------------------------------------------------- cross-cutting surfaces

    @Test
    void adminActionsTest() {
        runFeatureTest("admin-actions.feature");
    }

    @Test
    void attestationTest() {
        runFeatureTest("attestation.feature");
    }

    @Test
    void listingGrammarTest() {
        runFeatureTest("listing-grammar.feature");
    }

    @Test
    void errorEnvelopesTest() {
        runFeatureTest("error-envelopes.feature");
    }
}
