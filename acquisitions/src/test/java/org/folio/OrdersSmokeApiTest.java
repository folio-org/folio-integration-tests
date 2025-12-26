package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-orders")
public class OrdersSmokeApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("create-order-payment-not-required-fully-receive"),
    FEATURE_2("create-order-check-items"),
    FEATURE_3("delete-one-piece-in-receiving"),
    FEATURE_4("change-order-instance-connection");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public OrdersSmokeApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
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
  @DisplayName("(Thunderjet) Run features")
  @EnabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C743) Create Order Payment Not Required Fully Receive")
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderPaymentNotRequiredFullyReceive() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C358972) Create Order Check Items")
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderCheckItems() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C422159) Delete One Piece In Receiving")
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void deleteOnePieceInReceiving() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C354277) Change Order Instance Connection")
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void changeOrderInstanceConnection() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }
}
