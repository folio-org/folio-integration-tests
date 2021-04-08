package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EbsconetApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-ebsconet/features/";
  private static final String TEST_SUITE_NAME = "mod-ebsconet";
  // TEST_SUITE_ID and TEST_SECTION_ID are obtained from TestRail
  private static final long TEST_SUITE_ID = 742L;
  private static final long TEST_SECTION_ID = 11516L;

  public EbsconetApiTest() {
    super(new TestRailIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
  }

  @Test
  void getEbsconetOrderLine() {
      runFeatureTest("get-ebsconet-order-line");
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
