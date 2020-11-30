package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class CrossModulesApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/cross-modules/features/";
  private static final String TEST_SUITE_NAME = "cross-modules";
  private static final long TEST_SECTION_ID = 3348L;
  // TODO: make TEST_SUITE_ID different for each module
  private static final long TEST_SUITE_ID = 162L;

  public CrossModulesApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest("create-order-with-invoice-that-has-enough-money");
  }

  @Test
  void orderInvoiceRelation() {
    runFeatureTest("order-invoice-relation");
  }

  @BeforeAll
  public void crossModuleApiTestBeforeAll() {
    runFeature("classpath:domain/cross-modules/cross-modules-junit.feature");
  }

  @AfterAll
  public void crossModuleApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}

