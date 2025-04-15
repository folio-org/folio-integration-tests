package org.folio;

import java.util.Optional;
import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "dreamliner", module = "edge-rtac")
@Disabled("Migrated to Eureka")
class EdgeRtacTests extends TestBase {

  public EdgeRtacTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:core_platform/edge-rtac/features/")));
  }

  @BeforeAll
  public void setup() {
    runHook();
    runFeature("classpath:core_platform/edge-rtac/rtac-junit.feature");
  }

  @Test
  void rtacTest() {
    runFeatureTest("rtac");
  }

  @Test
  void rtacFromOrderPieceTest() {
    runFeatureTest("rtac-from-order-piece");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Override
  public void runHook() {
    Optional.ofNullable(System.getenv("karate.env"))
        .ifPresent(env -> System.setProperty("karate.env", env));
    System.setProperty("testTenant", "testrtac");
  }
}
