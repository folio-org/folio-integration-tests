package org.folio;

import org.folio.shared.SharedOrdersTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@Order(5)
@FolioTest(team = "thunderjet", module = "mod-orders")
public class OrdersSmokeApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;


  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("create-order-payment-not-required-fully-receive", true),
    FEATURE_2("create-order-check-items", true),
    FEATURE_3("delete-one-piece-in-receiving", true),
    FEATURE_4("change-order-instance-connection", true);

    private final String fileName;
    private final boolean isEnabled;

    Feature(String fileName, boolean isEnabled) {
      this.fileName = fileName;
      this.isEnabled = isEnabled;
    }

    public boolean isEnabled() {
      return isEnabled;
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
    SharedOrdersTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  public void ordersSmokeApiTestAfterAll() {
    SharedOrdersTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C743) Create Order Payment Not Required Fully Receive")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderPaymentNotRequiredFullyReceive() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C358972) Create Order Check Items")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderCheckItems() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C422159) Delete One Piece In Receiving")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deleteOnePieceInReceiving() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C354277) Change Order Instance Connection")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changeOrderInstanceConnection() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }
}
