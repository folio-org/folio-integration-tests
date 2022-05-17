package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "vega", module = "mod-notify")
public class ModNotifyTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:vega/mod-notify/features/";

  public ModNotifyTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:vega/mod-notify/notify-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void notifyTest() {
    runFeatureTest("notify");
  }

  @Test
  void patronNoticeTest() {
    runFeatureTest("patronNotice");
  }
}
