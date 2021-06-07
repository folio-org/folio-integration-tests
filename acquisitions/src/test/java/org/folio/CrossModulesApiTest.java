package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class CrossModulesApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/cross-modules/features/";

  public CrossModulesApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void checkEncumbrancesAfterOrderIsReopened() {
    runFeatureTest("check-encumbrances-after-order-is-reopened.feature");
  }

  @Test
  void checkEncumbrancesAfterOrderIsReopened2() {
    runFeatureTest("check-encumbrances-after-order-is-reopened-2.feature");
  }

  @Test
  void createOrderWithInvoiceWithEnoughMoney() {
    runFeatureTest("create-order-with-invoice-that-has-enough-money");
  }

  @Test
  void createOrderAndInvoiceWithOddPenny() {
    runFeatureTest("create-order-and-invoice-with-odd-penny.feature");
  }

  @Test
  void orderInvoiceRelation() {
    runFeatureTest("order-invoice-relation");
  }

  @Test
  void unopen_order_and_add_addition_pol_and_check_encumbrances() {
    runFeatureTest("unopen-order-and-add-addition-pol-and-check-encumbrances");
  }

  @Test
  void unopen_order_simple_case() {
    runFeatureTest("unopen-order-simple-case");
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

