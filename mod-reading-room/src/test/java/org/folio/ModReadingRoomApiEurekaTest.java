package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@Disabled
@FolioTest(team = "volaris", module = "mod-reading-room")
class ModReadingRoomApiEurekaTest extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-reading-room/eureka-features/";

  public ModReadingRoomApiEurekaTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-reading-room/reading-room-init-eureka.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void readingRoomTests() {
    runFeatureTest("reading-room");
  }
  @Test
  void patronPermissionTests() {
    runFeatureTest("patron-permission");
  }
}
