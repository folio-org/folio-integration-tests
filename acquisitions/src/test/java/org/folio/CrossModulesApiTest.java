package org.folio;

import java.io.IOException;
import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class CrossModulesApiTest extends AbstractTestRailIntegrationTest {

  private static final String TEST_SUITE_NAME = "cross-modules";
  private static final Long DEFAULT_SUITE_ID = 111l;
  private static final Long DEFAULT_SECTION_ID = 1385l;

  private static String TEST_BASE_PATH = "classpath:domain/cross-modules/features/";

  public CrossModulesApiTest() {
    super(TEST_BASE_PATH, TEST_SUITE_NAME, DEFAULT_SUITE_ID, DEFAULT_SECTION_ID);
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() throws IOException {
    runFeatureTest("create-order-with-invoice-that-has-enough-money");
  }

  @Test
  void orderInvoiceRelation() throws IOException {
    runFeatureTest("order-invoice-relation");
  }

  @BeforeAll
  public static void crossModuleApiTestBeforeAll() {
    runFeature("classpath:domain/cross-modules/cross-modules-junit.feature");
  }

  @AfterAll
  public static void crossModuleApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}