package org.folio;

import org.folio.shared.SharedOrdersTenant;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.folio.test.services.TestRailService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

@Order(4)
@FolioTest(team = "thunderjet", module = "mod-orders")
public class OrdersCriticalPathApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;

  private boolean createdSharedTenant = false;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("receive-piece-new-holding-edit", true);

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

  public OrdersCriticalPathApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  public void ordersSmokeApiTestBeforeAll() {
    createdSharedTenant = SharedOrdersTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  public void ordersSmokeApiTestAfterAll() {
    SharedOrdersTenant.cleanupTenant(createdSharedTenant, this::runFeature);
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C844840) Piece received via receiving full-screen in a new holding can be edited")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderPaymentNotRequiredFullyReceive() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }
}
