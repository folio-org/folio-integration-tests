package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "cross-modules")
public class CrossModulesCriticalPathApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/cross-modules/features/";

  public CrossModulesCriticalPathApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void crossModulesCriticalPathApiTestBeforeAll() {
    System.setProperty("testTenant", "testcross" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/cross-modules/init-cross-modules.feature");
  }

  @AfterAll
  public void crossModulesCriticalPathApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void encumbranceCalculatedCorrectlyForUnopenedOngoingOrderWithApprovedInvoice() {
    runFeatureTest("encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice");
  }

  @Test
  void encumbranceRemains0For0DollarOngoingOrderAfterCancelingPaidInvoiceUnreleasingEncumbranceAndCancelingAnotherPaidInvoice() {
    runFeatureTest("encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice");
  }

  @Test
  void encumbranceRemains0ForReOpened0DollarOngoingOrderWithPaidInvoiceUnreleasingEncumbranceAndCancelingPaidInvoiceReleaseEncumbranceTrue() {
    runFeatureTest("encumbrance-remains-0-for-re-opened-0-dollar-ongoing-order-with-paid-invoice");
  }
}
