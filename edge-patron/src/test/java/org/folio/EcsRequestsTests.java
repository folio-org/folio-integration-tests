package org.folio;

import static java.lang.System.setProperty;

import java.util.UUID;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
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

  @AfterAll
  void tearDown() {
    runFeature("classpath:consortia/destroy-data.feature");
  }

  @Test
  void ecsRequestsTest() {
    runFeatureTest("ecs-requests.feature");
  }

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
