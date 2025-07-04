package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "core-platform", module = "mod-permissions")
@Deprecated(forRemoval = true)
@Disabled
public class ModPermissionsTests extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:core_platform/mod-permissions/";

  public ModPermissionsTests() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeatureTest("permissions-junit");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }

  @Test
  void orchestrate() {
    runFeatureTest("features/permissions");
  }
}
