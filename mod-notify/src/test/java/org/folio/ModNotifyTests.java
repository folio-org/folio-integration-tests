package org.folio;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.util.Arrays;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.util.SocketUtils;
import org.subethamail.smtp.server.SMTPServer;
import org.subethamail.wiser.Wiser;

import com.icegreen.greenmail.util.GreenMail;
import com.icegreen.greenmail.util.ServerSetup;
import com.icegreen.greenmail.util.ServerSetupTest;

public class ModNotifyTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-notify/features/";

  public ModNotifyTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  private GreenMail greenMail;

  private Wiser wiser;

  @BeforeAll
  public void setup() throws IOException {
    runFeature("classpath:domain/mod-notify/notify-junit.feature");
  /*  greenMail = new GreenMail();
    greenMail.start();*/
    wiser = new Wiser();
    wiser.setPort(2500);
    wiser.start();
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
    //greenMail.stop();
    wiser.stop();
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
