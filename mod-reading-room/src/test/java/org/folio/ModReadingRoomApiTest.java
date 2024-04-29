package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-reading-room")
class ModReadingRoomApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-reading-room/features/";

  public ModReadingRoomApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-reading-room/reading-room-init.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }
  
  @Test
  void readingRoomTests() {
    runFeatureTest("reading-room");
  }
}
