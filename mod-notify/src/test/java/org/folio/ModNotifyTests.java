package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import com.icegreen.greenmail.util.GreenMail;
import com.icegreen.greenmail.util.ServerSetup;
import com.icegreen.greenmail.util.ServerSetupTest;

public class ModNotifyTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-notify/features/";

  public ModNotifyTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  private GreenMail greenMail;

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/mod-notify/notify-junit.feature");
    greenMail = new GreenMail(ServerSetupTest.ALL);
    greenMail.start();
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
    greenMail.stop();
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
