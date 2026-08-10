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
    System.setProperty("consortiumId", UUID.randomUUID().toString());

    System.setProperty("centralTenantId", UUID.randomUUID().toString());
    System.setProperty("collegeTenantId", UUID.randomUUID().toString());
    System.setProperty("universityTenantId", UUID.randomUUID().toString());

    // Fix all three tenant names to deterministic values so the consortium can be reused
    // across runs. FAT-27028 runs with -DrandomNumbers=mr1 (CI convention), which creates
    // consortiummr1, collegemr1, universitymr1. Using the same suffix here prevents
    // setup from trying to recreate universitymr1 (already exists), which would disrupt
    // mod-requests-mediated Kafka consumers and cause the 'Open - Awaiting pickup' assertion
    // to time out at line 417.
    System.setProperty("randomNumbers", "mr1");
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
