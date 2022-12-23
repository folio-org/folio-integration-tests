package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-audit")
public class ModAuditApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-audit/features/";

  public ModAuditApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:thunderjet/mod-audit/mod-audit-junit.feature");
  }

  @Test
  void orderEventTests() { runFeatureTest("orderEvent"); }

  @Test
  void orderLineEventTests() { runFeatureTest("orderLineEvent"); }

}
