package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-invoice")
public class InvoicesSmokeApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-invoice/features/";

  public InvoicesSmokeApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void invoicesSmokeApiTestBeforeAll() {
    System.setProperty("testTenant", "testinvoice" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-invoice/init-invoice.feature");
  }

  @AfterAll
  public void invoicesSmokeApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) (C357044) Pay Invoice With 0 Value")
  void payInvoiceWith0Value() {
    runFeatureTest("pay-invoice-with-0-value");
  }
}
