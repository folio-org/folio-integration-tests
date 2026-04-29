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
    FEATURE_3("update-po-lines-when-order-cancelled", true),
    // moved from OrdersSmokeApiTest (TestRail group = Extended)
    FEATURE_4("create-order-payment-not-required-fully-receive", true),
    FEATURE_5("create-order-check-items", true),
    FEATURE_6("delete-one-piece-in-receiving", true),
    FEATURE_7("change-order-instance-connection", true),
    // moved from OrdersCriticalPathApiTest (TestRail group = Extended)
    FEATURE_8("unopen-order-delete-empty-holding-two-locs", true),
    FEATURE_9("unopen-order-delete-empty-holding-two-pols", true),
    FEATURE_10("unopen-order-delete-empty-holding-mixed-pols", true),
    FEATURE_11("pe-mix-change-instance-connection-create-new-delete-holdings", true),
    FEATURE_12("pe-mix-synchronized-change-instance-connection-create-new-delete-holdings", true),
    FEATURE_13("physical-change-instance-connection-find-create-delete-holdings", true);

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

  // --- moved from OrdersSmokeApiTest ---

  @Test
  @DisplayName("(Thunderjet) (C743) Create Order Payment Not Required Fully Receive")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderPaymentNotRequiredFullyReceive() {
    runFeatureTest(Feature.FEATURE_4.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C358972) Create Order Check Items")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderCheckItems() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C422159) Delete One Piece In Receiving")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deleteOnePieceInReceiving() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C354277) Change Order Instance Connection")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changeOrderInstanceConnection() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  // --- moved from OrdersCriticalPathApiTest ---

  @Test
  @DisplayName("(Thunderjet) (C1273160) Unopen independent POL with 2 locations - only empty holding deleted")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopenOrderDeleteEmptyHoldingTwoLocs() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1273166) Unopen order with 2 independent POLs - only empty holding deleted")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopenOrderDeleteEmptyHoldingTwoPols() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C1273167) Unopen order with synchronized and independent POLs - only empty holding deleted")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unopenOrderDeleteEmptyHoldingMixedPols() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C784423) P/E Mix Change Instance Connection Create New Holdings Delete Abandoned Holdings")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void peMixChangeInstanceConnectionCreateNewDeleteHoldings() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C784425) P/E Mix Synchronized Change Instance Connection Create New Holdings Delete Abandoned Holdings")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void peMixSynchronizedChangeInstanceConnectionCreateNewDeleteHoldings() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisplayName("(Thunderjet) (C784421) Change instance connection for physical order with independent workflow (\"Find or create new\") when piece is received in a new location (\"Delete holdings\")")
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void physicalChangeInstanceConnectionFindCreateDeleteHoldings() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

}