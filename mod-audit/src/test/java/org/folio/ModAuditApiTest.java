package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class ModAuditApiTest extends TestBase {
  private static final String TEST_BASE_PATH = "classpath:domain/mod-audit/features/";

  public ModAuditApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void setup() {
    runFeature("classpath:domain/mod-audit/mod-audit-junit.feature");
  }

  @AfterAll
  public void tearDown() {
    runFeature("classpath:common/destroy-data.feature");
  }
  
  @Test
  void feefineEventTests() {
    runFeatureTest("feefineEvent");
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
  void manualBlockEventTests() {
    runFeatureTest("manualBlockEvent");
  }
  
  @Test
  void noticeEventTests() {
    runFeatureTest("noticeEvent");
  }
  
  @Test
  void checkInCheckOutTests() {
    runFeatureTest("checkInCheckOutEvent");
  }
}
