package org.folio;

import java.util.UUID;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "folio-ecs-circulation")
class FolioEcsCirculationTests extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:vega/systemwide-service-points/features/";

  public FolioEcsCirculationTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
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
  }

  @Test
  void folioEcsCirculationTests() {
    runFeatureTest("systemwide-service-points");
  }
}
