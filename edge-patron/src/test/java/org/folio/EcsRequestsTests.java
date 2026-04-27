package org.folio;

import static java.lang.System.setProperty;

import java.util.UUID;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "edge-patron")
class EcsRequestsTests extends TestBaseEureka {

  public EcsRequestsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:consortia/features/")));
  }

  @BeforeAll
  void setup() {
    runFeature("classpath:consortia/init-consortia.feature");
  }

  @Test
  void ecsRequestsTest() {
    runFeatureTest("ecs-requests.feature");
  }

  // Batch ECS request test is intentionally disabled:
  // - It requires additional batch-specific initialization (see `consortia/init-batch-consortia.feature`).
  // - Re-enable once the environment/data dependencies are stable and the feature is verified.
  //  @Test
  //  void batchEcsRequestsTest() {
  //    runFeatureTest("batch-ecs-requests.feature");
  //  }

  @Override
  public void runHook() {
    super.runHook();
    setProperty("centralAdminId", randomUUID());
    setProperty("centralUserId", randomUUID());
    setProperty("universityUserId",randomUUID());

    setProperty("consortiumId", randomUUID());

    setProperty("randomNumbers", String.valueOf(java.lang.System.currentTimeMillis()));

    setProperty("centralTenantId", randomUUID());
    setProperty("universityTenantId", randomUUID());
  }

  private String randomUUID() {
    return UUID.randomUUID().toString();
  }
}
