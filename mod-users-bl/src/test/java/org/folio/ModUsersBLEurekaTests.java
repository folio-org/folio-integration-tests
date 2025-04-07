package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-users-bl")
@Disabled("REMOVE AFTER THE TESTS")
public class ModUsersBLEurekaTests extends TestBaseEureka {
  private static final String TEST_BASE_PATH = "classpath:volaris/mod-users-bl/eureka-features/";

  public ModUsersBLEurekaTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:volaris/mod-users-bl/users-bl-junit-eureka.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void login() {
    runFeatureTest("users-bl.feature");
  }
}
