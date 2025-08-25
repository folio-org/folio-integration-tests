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

@FolioTest(team = "thunderjet", module = "mod-orders")
public class OrdersSmokeApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";

  public OrdersSmokeApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  public void ordersSmokeApiTestBeforeAll() {
    System.setProperty("testTenant", "testorders" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-orders/init-orders.feature");
  }

  @AfterAll
  public void ordersSmokeApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  void createOrderPaymentNotRequiredFullyReceive() {
    runFeatureTest("create-order-payment-not-required-fully-receive");
  }

  @Test
  void createOrderCheckItems() {
    runFeatureTest("create-order-check-items");
  }

  @Test
  void deleteOnePieceInReceiving() {
    runFeatureTest("delete-one-piece-in-receiving");
  }

  @Test
  void changeOrderInstanceConnection() {
    runFeatureTest("change-order-instance-connection");
  }
}
