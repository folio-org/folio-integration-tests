package org.folio;

import org.folio.shared.AcquisitionsTest;
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
class OrdersExtendedApiTest extends TestBaseEureka implements AcquisitionsTest {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("piece-status-transitions-claiming", true),
    FEATURE_2("add-piece-to-cancelled-order", true),
    FEATURE_3("update-po-lines-when-order-cancelled", true);

    private final String fileName;
    private final boolean isEnabled;

    Feature(String fileName, boolean isEnabled) {
      this.fileName = fileName;
      this.isEnabled = isEnabled;
    }

    public String getFileName() {
      return fileName;
    }

    public boolean isEnabled() {
      return isEnabled;
    }
  }

  public OrdersExtendedApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)), new TestRailService());
  }

  @BeforeAll
  @Override
  public void beforeAll() {
    SharedOrdersTenant.initializeTenant(TEST_TENANT, this.getClass(), this::runFeature);
  }

  @AfterAll
  @Override
  public void afterAll() {
    SharedOrdersTenant.cleanupTenant(this.getClass(), this::runFeature);
  }

  @Test
  @Override
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  public void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisplayName("(Thunderjet) (C436738, C436793, C436794) Piece Status Transitions Claiming")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceStatusTransitionsClaiming() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C543756, C553012) Add piece to cancelled order")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void addPieceToCancelledOrder() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C353543) Update po lines when an order is closed with the 'Cancelled' reason")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updatePoLinesWhenOrderCancelled() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }
}