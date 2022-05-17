package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "prokopovych", module = "mod-users")
class ModUsersTests extends TestBase {

  public ModUsersTests() {
    super(new TestIntegrationService(new TestModuleConfiguration("classpath:prokopovych/mod-users/features/")));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:prokopovych/mod-users/users-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void usersTest() {
    runFeatureTest("users");
  }
}
