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

@FolioTest(team = "vega", module = "folio-ecs-circulation")
// The ECS features recreate consortium tenants and share the configured secure tenant
// (universitymr1). Keep this class deterministic and run mediated requests before the
// other consortium setups so delayed Kafka events cannot affect its workflow.
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Execution(ExecutionMode.SAME_THREAD)
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
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:vega/systemwide-service-points/destroy-consortia.feature");
    runFeature("classpath:vega/ecs-requests/destroy-ecs-requests.feature");
  }

  @Test
  @Order(2)
  void folioEcsCirculationTests() {
    runFeatureTest("systemwide-service-points");
  }

  @Test
  @Order(4)
  void ecsRequestsTests() {
    runFeature(ECS_REQUESTS_BASE_PATH + "ecs-requests.feature");
  }

  @Test
  @Order(3)
  void staffSlipsTests() {
    runFeature("classpath:vega/staff-slips/features/staff-slips.feature");
  }

  @Test
  @Order(1)
  void mediatedRequestsTests() {
    runFeature(MEDIATED_REQUESTS_BASE_PATH + "mediated-requests.feature");
  }
}
