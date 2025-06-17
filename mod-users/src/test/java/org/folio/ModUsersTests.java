package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-users")
class ModUsersTests extends TestBaseEureka {

  private boolean setupSuccessful = false;

  public ModUsersTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:volaris/mod-users/features/")));
  }

  @BeforeAll
  public void setup() {
    try {
      runFeature("classpath:volaris/mod-users/users-junit.feature");
      setupSuccessful = true;
    } catch (RuntimeException e) {
      System.err.println("=== setup failed, skipping all tests & teardown ===");
      throw e;
    }
  }

  @AfterAll
  public void tearDown() {
    if (!setupSuccessful) {
      System.out.println("==== Skipping destroy-data because setup never succeeded. ====");
      return;
    }

    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void usersTest() {
    runFeatureTest("users");
  }

  @Test
  void usersProfilePictureTest() {
    runFeatureTest("profile-picture");
  }
}
