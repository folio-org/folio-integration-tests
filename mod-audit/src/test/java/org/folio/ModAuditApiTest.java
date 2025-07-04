package org.folio;

import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

@FolioTest(team = "volaris", module = "mod-audit")
public class ModAuditApiTest extends TestBaseEureka {
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
    runFeature("classpath:common/eureka/destroy-data.feature");
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

  @Test
  void marcAuditDataTests() {
    runFeatureTest("marcAuditData");
  }

  @Test
  void instanceAuditDataTests() {
    runFeatureTest("instanceAuditData");
  }

  @Test
  void holdingAuditDataTests() {
    runFeatureTest("holdingAuditData");
  }

  @Test
  void itemAuditDataTests() {
    runFeatureTest("itemAuditData");
  }
}
