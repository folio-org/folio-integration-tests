package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@Order(3)
@FolioTest(team = "thunderjet", module = "mod-orders")
class OrdersApiTest extends TestBaseEureka {

  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final String TEST_TENANT = "testorders";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("bind-piece", true),
    FEATURE_2("cancel-and-delete-order", true),
    FEATURE_3("cancel-item-after-canceling-poline-in-multi-line-orders", true),
    FEATURE_4("cancel-order", true),
    FEATURE_5("change-location-when-receiving-piece", true),
    FEATURE_6("change-pending-distribution-with-inactive-budget", true),
    FEATURE_7("check-estimated-price-with-composite-order", true),
    FEATURE_8("check-holding-instance-creation-with-createInventory-options", true),
    FEATURE_9("check-new-tags-in-central-tag-repository", true),
    FEATURE_10("check-order-lines-number-retrieve-limit", true),
    FEATURE_11("check-re-encumber-property", true),
    FEATURE_12("close-order-and-release-encumbrances", true),
    FEATURE_13("close-order-including-lines", true),
    FEATURE_14("close-order-when-fully-paid-and-received", true),
    FEATURE_15("create-five-pieces", true),
    FEATURE_16("create-open-composite-order", true),
    FEATURE_17("create-order-that-has-not-enough-money", true),
    FEATURE_18("delete-fund-distribution", true),
    FEATURE_19("delete-opened-order-and-lines", true),
    FEATURE_20("encumbrance-released-when-order-closes", true),
    FEATURE_21("encumbrance-tags-inheritance", true),
    FEATURE_22("encumbrance-update-after-expense-class-change", true),
    FEATURE_23("expense-class-handling-for-order-and-lines", true),
    FEATURE_24("find-holdings-by-location-and-instance-for-mixed-pol", true),
    FEATURE_25("fund-codes-in-open-order-error", true),
    FEATURE_26("increase-poline-quantity-for-open-order", true),
    FEATURE_27("independent-acquisitions-unit-for-ordering-and-receiving", true),
    FEATURE_28("item-and-holding-operations-for-order-flows", true),
    FEATURE_29("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false", true),
    FEATURE_30("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true", true),
    FEATURE_31("MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false", true),
    FEATURE_32("MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package", true),
    FEATURE_33("MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item", true),
    FEATURE_34("move-item-and-holding-to-update-order-data", true),
    FEATURE_35("open-and-unopen-order", true),
    FEATURE_36("open-ongoing-order", true),
    FEATURE_37("open-ongoing-order-if-interval-or-renewaldate-notset", true),
    FEATURE_38("open-order-failure-side-effects", true),
    FEATURE_39("open-order-instance-link", true),
    FEATURE_40("open-order-success-with-expenditure-restrictions", true),
    FEATURE_41("open-orders-with-poLines", true),
    FEATURE_42("open-order-with-different-po-line-currency", true),
    FEATURE_43("open-order-with-manual-exchange-rate", true),
    FEATURE_44("open-order-with-many-product-ids", true),
    FEATURE_45("open-order-without-holdings", true),
    FEATURE_46("open-order-with-resolution-statuses", true),
    FEATURE_47("open-order-with-restricted-locations", true),
    FEATURE_48("open-order-with-the-same-fund-distributions", true),
    FEATURE_49("order-event", true),
    FEATURE_50("order-line-event", true),
    FEATURE_51("parallel-create-piece", true),
    FEATURE_52("parallel-update-order-lines-different-orders", true),
    FEATURE_53("parallel-update-order-lines-same-order", true),
    FEATURE_54("pe-mix-update-piece", true),
    FEATURE_55("piece-audit-history", true),
    FEATURE_56("piece-batch-job", true),
    FEATURE_57("piece-deletion-restriction", true),
    FEATURE_58("piece-operations-for-order-flows-mixed-order-line", false),
    FEATURE_59("pieces-batch-update-status", true),
    FEATURE_60("piece-status-transitions", true),
    FEATURE_61("poline_change_instance_connection", true),
    FEATURE_62("poline-change-instance-connection-with-holdings-items", true),
    FEATURE_63("poline-claiming-interval-checks", true),
    FEATURE_64("productIds-field-error-when-attempting-to-update-unmodified-order", true),
    FEATURE_65("receive-20-pieces", true),
    FEATURE_66("receive-piece-against-non-package-pol", true),
    FEATURE_67("receive-piece-against-package-pol", true),
    FEATURE_68("reopen-order-creates-encumbrances", true),
    FEATURE_69("reopen-order-with-50-lines", true),
    FEATURE_70("retrieve-titles-with-honor-of-acq-units", true),
    FEATURE_71("routing-list-print-template", true),
    FEATURE_72("routing-lists-api", true),
    FEATURE_73("should-decrease-quantity-when-delete-piece-with-no-location", true),
    FEATURE_74("three-fund-distributions", true),
    FEATURE_75("title-instance-creation", true),
    FEATURE_76("unlink-title", true),
    FEATURE_77("unopen-order-with-different-fund", true),
    FEATURE_78("unreceive-piece-and-check-order-line", true),
    FEATURE_79("update_fields_in_item", true),
    FEATURE_80("update-purchase-order-with-order-lines", true),
    FEATURE_81("update-purchase-order-workflow-status", true),
    FEATURE_82("validate-fund-distribution-for-zero-price", true),
    FEATURE_83("validate-pol-receipt-not-required-with-checkin-items", true),
    FEATURE_84("create-order-with-suppress-instance-from-discovery", true),
    FEATURE_85("auto-populate-fund-code", true),
    FEATURE_86("holding-detail", true),
    FEATURE_87("piece-item-synchronization", true);

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

  public OrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void ordersApiTestBeforeAll() {
    System.setProperty("testTenant", TEST_TENANT + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-orders/init-orders.feature");
  }

  @AfterAll
  void ordersApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @DisabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void bindPiece() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelAndDeleteOrder() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelItemAfterCancelingPolineInMultiLineOrders() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void cancelOrder() {
    runFeatureTest(Feature.FEATURE_4.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changeLocationWhenReceivingPiece() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void changePendingDistributionWithInactiveBudget() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkEstimatedPriceWithCompositeOrder() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkHoldingInstanceCreationWithCreateInventoryOptions() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkNewTagsCreatedInCentralTagRepository() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @Disabled
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkOrderLinesNumberRetrieveLimit() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void checkOrderNeedReEncumber() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void closeOrderAndReleaseEncumbrances() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void closeOrderIncludingLines() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void closeOrderWhenFullyPaidAndReceived() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createFivePieces() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOpenCompositeOrder() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderWithNotEnoughMoney() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deleteFundDistribution() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void deleteOpenedOrderAndOrderLines() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceReleasedWhenOrderCloses() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceTagsInheritance() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void encumbranceUpdateAfterExpenseClassChange() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void expenseClassHandlingOrderWithLines() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void findHoldingForMixedPol() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void fundCodesInOpenOrderError() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void increasePolineQuantityOpenOrder() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void independentAcquisitionsUnitForOrderReceiving() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void itemAndHoldingsOperations() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsFalse() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsTrue() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void manualPieceFlowUpdatePieceAgainstNonPackageMixedPolManualPieceCreationIsFalse() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void manualPieceFlowUpdatePiecePOLLocationNotUpdatedWhenPieceLocationEditedAgainstNonPackage() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void manualPieceFlowAddPieceWithoutItemThenOpenToUpdateAndSetCreateItem() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void moveItemAndHoldingToUpdateOrderData() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openAndUnopenOrder() {
    runFeatureTest(Feature.FEATURE_35.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOngoingOrder() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOngoingOrderIfIntervalOrRenewalDateNotSet() {
    runFeatureTest(Feature.FEATURE_37.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderFailureSideEffects() {
    runFeatureTest(Feature.FEATURE_38.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderInstanceLink() {
    runFeatureTest(Feature.FEATURE_39.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderSuccessWithExpenditureRestrictions() {
    runFeatureTest(Feature.FEATURE_40.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrdersWithPoLines() {
    runFeatureTest(Feature.FEATURE_41.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithDifferentPoLineCurrency() {
    runFeatureTest(Feature.FEATURE_42.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithManualExchangeRate() {
    runFeatureTest(Feature.FEATURE_43.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithManyProductIds() {
    runFeatureTest(Feature.FEATURE_44.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithoutHoldings() {
    runFeatureTest(Feature.FEATURE_45.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithResolutionPoLineStatuses() {
    runFeatureTest(Feature.FEATURE_46.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithRestrictedLocations() {
    runFeatureTest(Feature.FEATURE_47.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest(Feature.FEATURE_48.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderEventTests() {
    runFeatureTest(Feature.FEATURE_49.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void orderLineEventTests() {
    runFeatureTest(Feature.FEATURE_50.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void parallelCreatePiece() {
    runFeatureTest(Feature.FEATURE_51.getFileName(), 5);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void parallelUpdateOrderLinesDifferentOrders() {
    runFeatureTest(Feature.FEATURE_52.getFileName(), 5);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void parallelUpdateOrderLinesSameOrder() {
    runFeatureTest(Feature.FEATURE_53.getFileName(), 5);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void peMixUpdatePiece() {
    runFeatureTest(Feature.FEATURE_54.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceAuditHistory() {
    runFeatureTest(Feature.FEATURE_55.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceBatchJob() {
    runFeatureTest(Feature.FEATURE_56.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceDeletionRestriction() {
    runFeatureTest(Feature.FEATURE_57.getFileName());
  }

  @Test
  @Disabled
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceOperations() {
    runFeatureTest(Feature.FEATURE_58.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updatePiecesBatchStatus() {
    runFeatureTest(Feature.FEATURE_59.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceStatusTransitions() {
    runFeatureTest(Feature.FEATURE_60.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void poLineChangeInstanceConnection() {
    runFeatureTest(Feature.FEATURE_61.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void poLineChangeInstanceConnectionWithHoldingsItems() {
    runFeatureTest(Feature.FEATURE_62.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void polineClaimingIntervalChecks() {
    runFeatureTest(Feature.FEATURE_63.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void getPutCompositeOrder() {
    runFeatureTest(Feature.FEATURE_64.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void receive20Pieces() {
    runFeatureTest(Feature.FEATURE_65.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void receivePieceAgainstNonPackagePol() {
    runFeatureTest(Feature.FEATURE_66.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void receivePieceAgainstPackagePol() {
    runFeatureTest(Feature.FEATURE_67.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void reopenOrderCreatesEncumbrances() {
    runFeatureTest(Feature.FEATURE_68.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void reopenOrderWith50Lines() {
    runFeatureTest(Feature.FEATURE_69.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void retrieveTitlesWithHonorOfAcqUnits() {
    runFeatureTest(Feature.FEATURE_70.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void routingListPrintTemplate() {
    runFeatureTest(Feature.FEATURE_71.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void testRoutingListApi() {
    runFeatureTest(Feature.FEATURE_72.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void shouldDecreaseQuantityWhenDeletePieceWithNoLocation() {
    runFeatureTest(Feature.FEATURE_73.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void threeFundDistributions() {
    runFeatureTest(Feature.FEATURE_74.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void testTitleInstanceCreation() {
    runFeatureTest(Feature.FEATURE_75.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unlinkTitle() {
    runFeatureTest(Feature.FEATURE_76.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unOpenOrderWithDifferentFund() {
    runFeatureTest(Feature.FEATURE_77.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void unreceivePieceAndCheckOrderLine() {
    runFeatureTest(Feature.FEATURE_78.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updateFieldsInItemAfterUpdatingInPiece() {
    runFeatureTest(Feature.FEATURE_79.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updatePurchaseOrderWithOrderLines() {
    runFeatureTest(Feature.FEATURE_80.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void updatePurchaseOrderWorkflowStatus() {
    runFeatureTest(Feature.FEATURE_81.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void validateFundDistributionForZeroPrice() {
    runFeatureTest(Feature.FEATURE_82.getFileName(), THREAD_COUNT);
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void validatePoLineReceiptNotRequiredWithCheckinItems() {
    runFeatureTest(Feature.FEATURE_83.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void createOrderWithSuppressInstanceFromDiscovery() {
    runFeatureTest(Feature.FEATURE_84.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void autoPopulateFundCodeInPoLine() {
    runFeatureTest(Feature.FEATURE_85.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void retrieveHoldingDetailsWithPiecesAndItems() {
    runFeatureTest(Feature.FEATURE_86.getFileName());
  }

  @Test
  @EnabledIfSystemProperty(named = "test.mode", matches = "no-shared-pool")
  void pieceItemSynchronization() {
    runFeatureTest(Feature.FEATURE_87.getFileName());
  }
}
