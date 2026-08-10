package org.folio;

import java.util.UUID;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "folio-ecs-circulation")
class FolioEcsCirculationTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:vega/systemwide-service-points/features/";
  private static final String ECS_REQUESTS_BASE_PATH = "classpath:vega/ecs-requests/features/";
  private static final String MEDIATED_REQUESTS_BASE_PATH = "classpath:vega/mediated-requests/";

  public FolioEcsCirculationTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @Override
  public void runHook() {
    super.runHook();
    System.setProperty("consortiaAdminUserId", UUID.randomUUID().toString());
    System.setProperty("universityUserId", UUID.randomUUID().toString());
    System.setProperty("collegeUserId", UUID.randomUUID().toString());

    System.setProperty("centralTenantId", UUID.randomUUID().toString());
    System.setProperty("collegeTenantId", UUID.randomUUID().toString());
    System.setProperty("universityTenantId", UUID.randomUUID().toString());

    // Fix the randomNumbers suffix so all three tenant names are deterministic:
    //   centralTenant    = 'consortiummr1'
    //   collegeTenant    = 'collegemr1'
    //   universityTenant = 'universitymr1'  (already fixed in karate-config.js)
    // This allows the consortium setup to be skipped when all tenants already exist, preventing
    // mod-requests-mediated Kafka consumer disruption that would cause the async
    // 'Open - Awaiting pickup' status transition to time out.
    // NOTE: if ECS tests are re-enabled in this runner, move them to a separate runner class
    // (or use a different randomNumbers value) to avoid tenant-name conflicts.
    System.setProperty("randomNumbers", "mr1");
    // Fix the consortium ID so instance-sharing operations use the same consortium across
    // runs when the full setup is reused.
    System.setProperty("consortiumId", "5a00852d-49fd-4df2-a1f9-000000000001");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:vega/systemwide-service-points/destroy-consortia.feature");
    runFeature("classpath:vega/ecs-requests/destroy-ecs-requests.feature");
  }

//  @Test
//  void folioEcsCirculationTests() {
//    runFeatureTest("systemwide-service-points");
//  }
//
//  @Test
//  void ecsRequestsTests() {
//    runFeature(ECS_REQUESTS_BASE_PATH + "ecs-requests.feature");
//  }
//
//  @Test
//  void staffSlipsTests() {
//    runFeature("classpath:vega/staff-slips/features/staff-slips.feature");
//  }

  @Test
  void mediatedRequestsTests() {
    runFeature(MEDIATED_REQUESTS_BASE_PATH + "mediated-requests.feature");
  }
}
