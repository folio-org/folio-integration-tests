package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ModAuditApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:firebird/mod-audit/features/";

  public ModAuditApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:firebird/mod-audit/mod-audit-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }
  
  @Test
  void loanEventTests() {
    runFeatureTest("loanEvent");
  }

  @Test
  void requestEventTests() {
    runFeatureTest("requestEvent");
  }
  
  @Test
  void checkInCheckOutTests() {
    runFeatureTest("checkInCheckOutEvent");
  }
}
