package org.folio;

import java.util.UUID;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;
import org.junit.jupiter.api.parallel.ResourceLock;

@FolioTest(team = "vega", module = "folio-ecs-circulation")
// ---------------------------------------------------------------------------------------------
// TENANT LIFECYCLE
//
// Every feature in this module derives its tenant names from the same three lines of
// karate-config.js, so they all share ONE tenant name-space:
//
//     consortium<randomNumbers> / college<randomNumbers> / universitymr1
//
// The tenants and the consortium are created exactly once, by bootstrapConsortium() below, and
// destroyed exactly once, by tearDown(). No feature may create or delete a tenant. Previously
// each feature deleted and recreated this name-space from its own setup feature, which produced
// Keycloak 409 "Failed to create realm for tenant" failures plus mediated-request workflows that
// stalled half-way through because the central tenant vanished underneath them.
//
// ISOLATION
//
// @Order and @Execution(SAME_THREAD) only serialise the methods of THIS class in THIS JVM. They
// provide no protection against a second Jenkins executor, a concurrent job, or another test
// class running against the same environment. Because the secure tenant name is fixed (it must
// equal mod-requests-mediated's SECURE_TENANT_ID, which is set at deploy time and cannot be read
// or randomised through any FOLIO API) it is a singleton resource on the environment: the Jenkins
// job MUST hold an environment-level lock, e.g.
//
//     lock(resource: "folio-ecs-circulation-${ENV}") { ... }
//
// @ResourceLock below adds the equivalent guarantee for other test classes inside this JVM.
// ---------------------------------------------------------------------------------------------
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Execution(ExecutionMode.SAME_THREAD)
@ResourceLock(FolioEcsCirculationTests.ECS_TENANTS)
class FolioEcsCirculationTests extends TestBaseEureka {

  /** Guards the shared consortium/college/secure tenant name-space against other test classes. */
  static final String ECS_TENANTS = "folio-ecs-circulation-tenants";

  private static final String TEST_BASE_PATH = "classpath:vega/systemwide-service-points/features/";
  private static final String ECS_REQUESTS_BASE_PATH = "classpath:vega/ecs-requests/features/";
  private static final String MEDIATED_REQUESTS_BASE_PATH = "classpath:vega/mediated-requests/";
  private static final String BOOTSTRAP_FEATURE = "classpath:vega/common/consortium-bootstrap.feature";

  public FolioEcsCirculationTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @Override
  public void runHook() {
    super.runHook();
    System.setProperty("consortiaAdminUserId", UUID.randomUUID().toString());
    System.setProperty("universityUserId", UUID.randomUUID().toString());
    System.setProperty("collegeUserId", UUID.randomUUID().toString());
    System.setProperty("consortiumId", UUID.randomUUID().toString());

    System.setProperty("centralTenantId", UUID.randomUUID().toString());
    System.setProperty("collegeTenantId", UUID.randomUUID().toString());
    System.setProperty("universityTenantId", UUID.randomUUID().toString());

    // Pin the tenant-name suffix for the whole JVM. karate-config.js is re-evaluated before every
    // Scenario, so without this the suffix - and therefore the central/college tenant NAMES -
    // drifted from scenario to scenario, while the tenant UUIDs above stayed fixed. That mismatch
    // both broke cross-feature reuse and left @AfterAll deleting names that were never created,
    // leaking Keycloak realms into the next build.
    //
    // Set once and only if absent, so that (a) it survives regardless of how often this hook is
    // invoked, and (b) a Jenkins job can pin a suffix of its own with -DrandomNumbers=<suffix>
    // (needed when mod-requests-mediated's SECURE_TENANT_ID is 'university<suffix>').
    if (System.getProperty("randomNumbers") == null) {
      System.setProperty("randomNumbers", uniqueTenantSuffix());
    }
  }

  /** 10 lowercase alphanumeric characters - valid as a Keycloak realm and DB schema suffix. */
  private static String uniqueTenantSuffix() {
    return UUID.randomUUID().toString().replace("-", "").substring(0, 10);
  }

  /**
   * Creates the three tenants and the consortium once, before any test feature runs.
   * Every feature below assumes this has completed.
   */
  @Test
  @Order(0)
  void bootstrapConsortium() {
    runFeature(BOOTSTRAP_FEATURE);
  }

  @Test
  @Order(1)
  void mediatedRequestsTests() {
    runFeature(MEDIATED_REQUESTS_BASE_PATH + "mediated-requests.feature");
  }

  @Test
  @Order(2)
  void folioEcsCirculationTests() {
    runFeatureTest("systemwide-service-points");
  }

  @Test
  @Order(3)
  void staffSlipsTests() {
    runFeature("classpath:vega/staff-slips/features/staff-slips.feature");
  }

  @Test
  @Order(4)
  void ecsRequestsTests() {
    runFeature(ECS_REQUESTS_BASE_PATH + "ecs-requests.feature");
  }

  /**
   * Single teardown for the single tenant name-space created by {@link #bootstrapConsortium()}.
   *
   * <p>Deliberately only one destroy feature. destroy-ecs-requests.feature used to be called here
   * as well, but it deleted a strict subset of the same three tenants - redundant at best, and
   * actively wrong if the tenant names ever drift. Do not add per-feature teardowns: per-feature
   * isolation would require per-feature tenant NAMES, which is impossible for the fixed secure
   * tenant.
   */
  @AfterAll
  public void tearDown() {
    runFeature("classpath:vega/systemwide-service-points/destroy-consortia.feature");
  }
}
