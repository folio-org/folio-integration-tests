package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EbsconetApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-ebsconet/features/";

  public EbsconetApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void getEbsconetOrderLine() {
      runFeatureTest("get-ebsconet-order-line");
  }

  @Test
  void updateEbsconetOrderLine() {
    runFeatureTest("update-ebsconet-order-line");
  }

  @BeforeAll
  public void ebsconetApiTestBeforeAll() {
      runFeature("classpath:domain/mod-ebsconet/ebsconet-junit.feature");
  }

  @AfterAll
  public void ebsconetApiTestAfterAll() {
      runFeature("classpath:common/destroy-data.feature");
  }

}
