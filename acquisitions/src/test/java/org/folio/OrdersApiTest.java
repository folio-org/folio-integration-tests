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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.DisabledIfSystemProperty;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-orders")
class OrdersApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final int THREAD_COUNT = 4;

  private enum Feature implements org.folio.test.config.CommonFeature {
    FEATURE_1("bind-piece"),
    FEATURE_2("cancel-and-delete-order"),
    FEATURE_3("cancel-item-after-canceling-poline-in-multi-line-orders"),
    FEATURE_4("cancel-order"),
    FEATURE_5("change-location-when-receiving-piece"),
    FEATURE_6("change-pending-distribution-with-inactive-budget"),
    FEATURE_7("check-estimated-price-with-composite-order"),
    FEATURE_8("check-holding-instance-creation-with-createInventory-options"),
    FEATURE_9("check-new-tags-in-central-tag-repository"),
    FEATURE_10("check-order-lines-number-retrieve-limit"),
    FEATURE_11("check-re-encumber-property"),
    FEATURE_12("close-order-and-release-encumbrances"),
    FEATURE_13("close-order-including-lines"),
    FEATURE_14("close-order-when-fully-paid-and-received"),
    FEATURE_15("create-five-pieces"),
    FEATURE_16("create-open-composite-order"),
    FEATURE_17("create-order-that-has-not-enough-money"),
    FEATURE_18("delete-fund-distribution"),
    FEATURE_19("delete-opened-order-and-lines"),
    FEATURE_20("encumbrance-released-when-order-closes"),
    FEATURE_21("encumbrance-tags-inheritance"),
    FEATURE_22("encumbrance-update-after-expense-class-change"),
    FEATURE_23("expense-class-handling-for-order-and-lines"),
    FEATURE_24("find-holdings-by-location-and-instance-for-mixed-pol"),
    FEATURE_25("fund-codes-in-open-order-error"),
    FEATURE_26("increase-poline-quantity-for-open-order"),
    FEATURE_27("independent-acquisitions-unit-for-ordering-and-receiving"),
    FEATURE_28("item-and-holding-operations-for-order-flows"),
    FEATURE_29("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false"),
    FEATURE_30("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true"),
    FEATURE_31("MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false"),
    FEATURE_32("MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package"),
    FEATURE_33("MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item"),
    FEATURE_34("move-item-and-holding-to-update-order-data"),
    FEATURE_35("open-and-unopen-order"),
    FEATURE_36("open-ongoing-order"),
    FEATURE_37("open-ongoing-order-if-interval-or-renewaldate-notset"),
    FEATURE_38("open-order-failure-side-effects"),
    FEATURE_39("open-order-instance-link"),
    FEATURE_40("open-order-success-with-expenditure-restrictions"),
    FEATURE_41("open-orders-with-poLines"),
    FEATURE_42("open-order-with-different-po-line-currency"),
    FEATURE_43("open-order-with-manual-exchange-rate"),
    FEATURE_44("open-order-with-many-product-ids"),
    FEATURE_45("open-order-without-holdings"),
    FEATURE_46("open-order-with-resolution-statuses"),
    FEATURE_47("open-order-with-restricted-locations"),
    FEATURE_48("open-order-with-the-same-fund-distributions"),
    FEATURE_49("order-event"),
    FEATURE_50("order-line-event"),
    FEATURE_51("parallel-create-piece"),
    FEATURE_52("parallel-update-order-lines-different-orders"),
    FEATURE_53("parallel-update-order-lines-same-order"),
    FEATURE_54("pe-mix-update-piece"),
    FEATURE_55("piece-audit-history"),
    FEATURE_56("piece-batch-job"),
    FEATURE_57("piece-deletion-restriction"),
    FEATURE_58("piece-operations-for-order-flows-mixed-order-line"),
    FEATURE_59("pieces-batch-update-status"),
    FEATURE_60("piece-status-transitions"),
    FEATURE_61("poline_change_instance_connection"),
    FEATURE_62("poline-change-instance-connection-with-holdings-items"),
    FEATURE_63("poline-claiming-interval-checks"),
    FEATURE_64("productIds-field-error-when-attempting-to-update-unmodified-order"),
    FEATURE_65("receive-20-pieces"),
    FEATURE_66("receive-piece-against-non-package-pol"),
    FEATURE_67("receive-piece-against-package-pol"),
    FEATURE_68("reopen-order-creates-encumbrances"),
    FEATURE_69("reopen-order-with-50-lines"),
    FEATURE_70("retrieve-titles-with-honor-of-acq-units"),
    FEATURE_71("routing-list-print-template"),
    FEATURE_72("routing-lists-api"),
    FEATURE_73("should-decrease-quantity-when-delete-piece-with-no-location"),
    FEATURE_74("three-fund-distributions"),
    FEATURE_75("title-instance-creation"),
    FEATURE_76("unlink-title"),
    FEATURE_77("unopen-order-with-different-fund"),
    FEATURE_78("unreceive-piece-and-check-order-line"),
    FEATURE_79("update_fields_in_item"),
    FEATURE_80("update-purchase-order-with-order-lines"),
    FEATURE_81("update-purchase-order-workflow-status"),
    FEATURE_82("validate-fund-distribution-for-zero-price"),
    FEATURE_83("validate-pol-receipt-not-required-with-checkin-items"),
    FEATURE_84("create-order-with-suppress-instance-from-discovery"),
    FEATURE_85("auto-populate-fund-code");

    private final String fileName;

    Feature(String fileName) {
      this.fileName = fileName;
    }

    public String getFileName() {
      return fileName;
    }
  }

  public OrdersApiTest() {
    super(new TestIntegrationService(new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @BeforeAll
  void ordersApiTestBeforeAll() {
    System.setProperty("testTenant", "testorders" + RandomUtils.nextLong());
    System.setProperty("testTenantId", UUID.randomUUID().toString());
    runFeature("classpath:thunderjet/mod-orders/init-orders.feature");
  }

  @AfterAll
  void ordersApiTestAfterAll() {
    runFeature("classpath:common/eureka/destroy-data.feature");
  }

  @Test
  @DisplayName("(Thunderjet) Run features")
  @EnabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void runFeatures() {
    runFeatures(Feature.values(), THREAD_COUNT, null);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void bindPiece() {
    runFeatureTest(Feature.FEATURE_1.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelAndDeleteOrder() {
    runFeatureTest(Feature.FEATURE_2.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelItemAfterCancelingPolineInMultiLineOrders() {
    runFeatureTest(Feature.FEATURE_3.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void cancelOrder() {
    runFeatureTest(Feature.FEATURE_4.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void changeLocationWhenReceivingPiece() {
    runFeatureTest(Feature.FEATURE_5.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void changePendingDistributionWithInactiveBudget() {
    runFeatureTest(Feature.FEATURE_6.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkEstimatedPriceWithCompositeOrder() {
    runFeatureTest(Feature.FEATURE_7.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkHoldingInstanceCreationWithCreateInventoryOptions() {
    runFeatureTest(Feature.FEATURE_8.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkNewTagsCreatedInCentralTagRepository() {
    runFeatureTest(Feature.FEATURE_9.getFileName());
  }

  @Test
  @Disabled
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkOrderLinesNumberRetrieveLimit() {
    runFeatureTest(Feature.FEATURE_10.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void checkOrderNeedReEncumber() {
    runFeatureTest(Feature.FEATURE_11.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void closeOrderAndReleaseEncumbrances() {
    runFeatureTest(Feature.FEATURE_12.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void closeOrderIncludingLines() {
    runFeatureTest(Feature.FEATURE_13.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void closeOrderWhenFullyPaidAndReceived() {
    runFeatureTest(Feature.FEATURE_14.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createFivePieces() {
    runFeatureTest(Feature.FEATURE_15.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOpenCompositeOrder() {
    runFeatureTest(Feature.FEATURE_16.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderWithNotEnoughMoney() {
    runFeatureTest(Feature.FEATURE_17.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void deleteFundDistribution() {
    runFeatureTest(Feature.FEATURE_18.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void deleteOpenedOrderAndOrderLines() {
    runFeatureTest(Feature.FEATURE_19.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void encumbranceReleasedWhenOrderCloses() {
    runFeatureTest(Feature.FEATURE_20.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void encumbranceTagsInheritance() {
    runFeatureTest(Feature.FEATURE_21.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void encumbranceUpdateAfterExpenseClassChange() {
    runFeatureTest(Feature.FEATURE_22.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void expenseClassHandlingOrderWithLines() {
    runFeatureTest(Feature.FEATURE_23.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void findHoldingForMixedPol() {
    runFeatureTest(Feature.FEATURE_24.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void fundCodesInOpenOrderError() {
    runFeatureTest(Feature.FEATURE_25.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void increasePolineQuantityOpenOrder() {
    runFeatureTest(Feature.FEATURE_26.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void independentAcquisitionsUnitForOrderReceiving() {
    runFeatureTest(Feature.FEATURE_27.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void itemAndHoldingsOperations() {
    runFeatureTest(Feature.FEATURE_28.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsFalse() {
    runFeatureTest(Feature.FEATURE_29.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsTrue() {
    runFeatureTest(Feature.FEATURE_30.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void manualPieceFlowUpdatePieceAgainstNonPackageMixedPolManualPieceCreationIsFalse() {
    runFeatureTest(Feature.FEATURE_31.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void manualPieceFlowUpdatePiecePOLLocationNotUpdatedWhenPieceLocationEditedAgainstNonPackage() {
    runFeatureTest(Feature.FEATURE_32.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void manualPieceFlowAddPieceWithoutItemThenOpenToUpdateAndSetCreateItem() {
    runFeatureTest(Feature.FEATURE_33.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void moveItemAndHoldingToUpdateOrderData() {
    runFeatureTest(Feature.FEATURE_34.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openAndUnopenOrder() {
    runFeatureTest(Feature.FEATURE_35.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOngoingOrder() {
    runFeatureTest(Feature.FEATURE_36.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOngoingOrderIfIntervalOrRenewalDateNotSet() {
    runFeatureTest(Feature.FEATURE_37.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderFailureSideEffects() {
    runFeatureTest(Feature.FEATURE_38.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderInstanceLink() {
    runFeatureTest(Feature.FEATURE_39.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderSuccessWithExpenditureRestrictions() {
    runFeatureTest(Feature.FEATURE_40.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrdersWithPoLines() {
    runFeatureTest(Feature.FEATURE_41.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithDifferentPoLineCurrency() {
    runFeatureTest(Feature.FEATURE_42.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithManualExchangeRate() {
    runFeatureTest(Feature.FEATURE_43.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithManyProductIds() {
    runFeatureTest(Feature.FEATURE_44.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithoutHoldings() {
    runFeatureTest(Feature.FEATURE_45.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithResolutionPoLineStatuses() {
    runFeatureTest(Feature.FEATURE_46.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithRestrictedLocations() {
    runFeatureTest(Feature.FEATURE_47.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest(Feature.FEATURE_48.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void orderEventTests() {
    runFeatureTest(Feature.FEATURE_49.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void orderLineEventTests() {
    runFeatureTest(Feature.FEATURE_50.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void parallelCreatePiece() {
    runFeatureTest(Feature.FEATURE_51.getFileName(), 5);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void parallelUpdateOrderLinesDifferentOrders() {
    runFeatureTest(Feature.FEATURE_52.getFileName(), 5);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void parallelUpdateOrderLinesSameOrder() {
    runFeatureTest(Feature.FEATURE_53.getFileName(), 5);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void peMixUpdatePiece() {
    runFeatureTest(Feature.FEATURE_54.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pieceAuditHistory() {
    runFeatureTest(Feature.FEATURE_55.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pieceBatchJob() {
    runFeatureTest(Feature.FEATURE_56.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pieceDeletionRestriction() {
    runFeatureTest(Feature.FEATURE_57.getFileName());
  }

  @Test
  @Disabled
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pieceOperations() {
    runFeatureTest(Feature.FEATURE_58.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updatePiecesBatchStatus() {
    runFeatureTest(Feature.FEATURE_59.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void pieceStatusTransitions() {
    runFeatureTest(Feature.FEATURE_60.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void poLineChangeInstanceConnection() {
    runFeatureTest(Feature.FEATURE_61.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void poLineChangeInstanceConnectionWithHoldingsItems() {
    runFeatureTest(Feature.FEATURE_62.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void polineClaimingIntervalChecks() {
    runFeatureTest(Feature.FEATURE_63.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void getPutCompositeOrder() {
    runFeatureTest(Feature.FEATURE_64.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void receive20Pieces() {
    runFeatureTest(Feature.FEATURE_65.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void receivePieceAgainstNonPackagePol() {
    runFeatureTest(Feature.FEATURE_66.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void receivePieceAgainstPackagePol() {
    runFeatureTest(Feature.FEATURE_67.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void reopenOrderCreatesEncumbrances() {
    runFeatureTest(Feature.FEATURE_68.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void reopenOrderWith50Lines() {
    runFeatureTest(Feature.FEATURE_69.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void retrieveTitlesWithHonorOfAcqUnits() {
    runFeatureTest(Feature.FEATURE_70.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void routingListPrintTemplate() {
    runFeatureTest(Feature.FEATURE_71.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void testRoutingListApi() {
    runFeatureTest(Feature.FEATURE_72.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void shouldDecreaseQuantityWhenDeletePieceWithNoLocation() {
    runFeatureTest(Feature.FEATURE_73.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void threeFundDistributions() {
    runFeatureTest(Feature.FEATURE_74.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void testTitleInstanceCreation() {
    runFeatureTest(Feature.FEATURE_75.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unlinkTitle() {
    runFeatureTest(Feature.FEATURE_76.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unOpenOrderWithDifferentFund() {
    runFeatureTest(Feature.FEATURE_77.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void unreceivePieceAndCheckOrderLine() {
    runFeatureTest(Feature.FEATURE_78.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updateFieldsInItemAfterUpdatingInPiece() {
    runFeatureTest(Feature.FEATURE_79.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updatePurchaseOrderWithOrderLines() {
    runFeatureTest(Feature.FEATURE_80.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void updatePurchaseOrderWorkflowStatus() {
    runFeatureTest(Feature.FEATURE_81.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void validateFundDistributionForZeroPrice() {
    runFeatureTest(Feature.FEATURE_82.getFileName(), THREAD_COUNT);
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void validatePoLineReceiptNotRequiredWithCheckinItems() {
    runFeatureTest(Feature.FEATURE_83.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void createOrderWithSuppressInstanceFromDiscovery() {
    runFeatureTest(Feature.FEATURE_84.getFileName());
  }

  @Test
  @DisabledIfSystemProperty(named = "test.mode", matches = "shared-pool")
  void autoPopulateFundCodeInPoLine() {
    runFeatureTest(Feature.FEATURE_85.getFileName());
  }
}
