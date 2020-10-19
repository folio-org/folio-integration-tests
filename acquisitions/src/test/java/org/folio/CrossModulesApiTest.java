package org.folio;

import static org.folio.testrail.config.TestConfigurationEnum.CROSS_MODULE_CONFIGURATION;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.TestRailIntegrationHelper;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class CrossModulesApiTest extends AbstractTestRailIntegrationTest {

  public CrossModulesApiTest() {
    super(new TestRailIntegrationHelper(CROSS_MODULE_CONFIGURATION));
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