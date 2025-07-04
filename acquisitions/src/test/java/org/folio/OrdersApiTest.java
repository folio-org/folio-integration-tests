package org.folio;

import org.apache.commons.lang3.RandomUtils;
import org.folio.test.TestBaseEureka;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import java.util.UUID;

@FolioTest(team = "thunderjet", module = "mod-orders")
class OrdersApiTest extends TestBaseEureka {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final int THREAD_COUNT = 4;

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
  void bindPiece() {
    runFeatureTest("bind-piece");
  }

  @Test
  void cancelAndDeleteOrder() {
    runFeatureTest("cancel-and-delete-order");
  }

  @Test
  void cancelItemAfterCancelingPolineInMultiLineOrders() {
    runFeatureTest("cancel-item-after-canceling-poline-in-multi-line-orders");
  }

  @Test
  void cancelOrder() {
    runFeatureTest("cancel-order", THREAD_COUNT);
  }

  @Test
  void changeLocationWhenReceivingPiece() {
    runFeatureTest("change-location-when-receiving-piece");
  }

  @Test
  void changePendingDistributionWithInactiveBudget() {
    runFeatureTest("change-pending-distribution-with-inactive-budget");
  }

  @Test
  void checkEstimatedPriceWithCompositeOrder() {
    runFeatureTest("check-estimated-price-with-composite-order");
  }

  @Test
  void checkHoldingInstanceCreationWithCreateInventoryOptions() {
    runFeatureTest("check-holding-instance-creation-with-createInventory-options");
  }

  @Test
  void checkNewTagsCreatedInCentralTagRepository() {
    runFeatureTest("check-new-tags-in-central-tag-repository");
  }

  @Test
  @Disabled
  void checkOrderLinesNumberRetrieveLimit() {
    runFeatureTest("check-order-lines-number-retrieve-limit");
  }

  @Test
  void checkOrderNeedReEncumber() {
    runFeatureTest("check-re-encumber-property");
  }

  @Test
  void closeOrderAndReleaseEncumbrances() {
    runFeatureTest("close-order-and-release-encumbrances");
  }

  @Test
  void closeOrderIncludingLines() {
    runFeatureTest("close-order-including-lines");
  }

  @Test
  void closeOrderWhenFullyPaidAndReceived() {
    runFeatureTest("close-order-when-fully-paid-and-received");
  }

  @Test
  void createFivePieces() {
    runFeatureTest("create-five-pieces");
  }

  @Test
  void createOpenCompositeOrder() {
    runFeatureTest("create-open-composite-order");
  }

  @Test
  void createOrderWithNotEnoughMoney() {
    runFeatureTest("create-order-that-has-not-enough-money");
  }

  @Test
  void deleteFundDistribution() {
    runFeatureTest("delete-fund-distribution");
  }

  @Test
  void deleteOpenedOrderAndOrderLines() {
    runFeatureTest("delete-opened-order-and-lines");
  }

  @Test
  void encumbranceReleasedWhenOrderCloses() {
    runFeatureTest("encumbrance-released-when-order-closes");
  }

  @Test
  void encumbranceTagsInheritance() {
    runFeatureTest("encumbrance-tags-inheritance");
  }

  @Test
  void encumbranceUpdateAfterExpenseClassChange() {
    runFeatureTest("encumbrance-update-after-expense-class-change");
  }

  @Test
  void expenseClassHandlingOrderWithLines() {
    runFeatureTest("expense-class-handling-for-order-and-lines");
  }

  @Test
  void findHoldingForMixedPol() {
    runFeatureTest("find-holdings-by-location-and-instance-for-mixed-pol");
  }

  @Test
  void fundCodesInOpenOrderError() {
    runFeatureTest("fund-codes-in-open-order-error");
  }

  @Test
  void increasePolineQuantityOpenOrder() {
    runFeatureTest("increase-poline-quantity-for-open-order");
  }

  @Test
  void independentAcquisitionsUnitForOrderReceiving() {
    runFeatureTest("independent-acquisitions-unit-for-ordering-and-receiving");
  }

  @Test
  void itemAndHoldingsOperations() {
    runFeatureTest("item-and-holding-operations-for-order-flows");
  }

  @Test
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsFalse() {
    runFeatureTest("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false");
  }

  @Test
  void manualPieceFlowCreateAndDeletePiecesPieceAgainstNonPackageMixedPolManualIsTrue() {
    runFeatureTest("MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true");
  }

  @Test
  void manualPieceFlowUpdatePieceAgainstNonPackageMixedPolManualPieceCreationIsFalse() {
    runFeatureTest("MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false");
  }

  @Test
  void manualPieceFlowUpdatePiecePOLLocationNotUpdatedWhenPieceLocationEditedAgainstNonPackage() {
    runFeatureTest("MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package");
  }

  @Test
  void manualPieceFlowAddPieceWithoutItemThenOpenToUpdateAndSetCreateItem() {
    runFeatureTest("MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item");
  }

  @Test
  void moveItemAndHoldingToUpdateOrderData() {
    runFeatureTest("move-item-and-holding-to-update-order-data");
  }

  @Test
  void openAndUnopenOrder() {
    runFeatureTest("open-and-unopen-order", THREAD_COUNT);
  }

  @Test
  void openOngoingOrder() {
    runFeatureTest("open-ongoing-order");
  }

  @Test
  void openOngoingOrderIfIntervalOrRenewalDateNotSet() {
    runFeatureTest("open-ongoing-order-if-interval-or-renewaldate-notset");
  }

  @Test
  void openOrderFailureSideEffects() {
    runFeatureTest("open-order-failure-side-effects");
  }

  @Test
  void openOrderInstanceLink() {
    runFeatureTest("open-order-instance-link");
  }

  @Test
  void openOrderSuccessWithExpenditureRestrictions() {
    runFeatureTest("open-order-success-with-expenditure-restrictions");
  }

  @Test
  void openOrdersWithPoLines() {
    runFeatureTest("open-orders-with-poLines");
  }

  @Test
  void openOrderWithDifferentPoLineCurrency() {
    runFeatureTest("open-order-with-different-po-line-currency");
  }

  @Test
  void openOrderWithManualExchangeRate() {
    runFeatureTest("open-order-with-manual-exchange-rate");
  }

  @Test
  void openOrderWithoutHoldings() {
    runFeatureTest("open-order-without-holdings");
  }

  @Test
  void openOrderWithResolutionPoLineStatuses() {
    runFeatureTest("open-order-with-resolution-statuses");
  }

  @Test
  void openOrderWithRestrictedLocations() {
    runFeatureTest("open-order-with-restricted-locations");
  }

  @Test
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest("open-order-with-the-same-fund-distributions");
  }

  @Test
  void orderEventTests() {
    runFeatureTest("order-event");
  }

  @Test
  void orderLineEventTests() {
    runFeatureTest("order-line-event");
  }

  @Test
  void parallelCreatePiece() {
    runFeatureTest("parallel-create-piece", 5);
  }

  @Test
  void parallelUpdateOrderLinesDifferentOrders() {
    runFeatureTest("parallel-update-order-lines-different-orders", 5);
  }

  @Test
  void parallelUpdateOrderLinesSameOrder() {
    runFeatureTest("parallel-update-order-lines-same-order", 5);
  }

  @Test
  void peMixUpdatePiece() {
    runFeatureTest("pe-mix-update-piece");
  }

  @Test
  void pieceAuditHistory() {
    runFeatureTest("piece-audit-history");
  }

  @Test
  void pieceBatchJob() {
    runFeatureTest("piece-batch-job");
  }

  @Test
  void pieceDeletionRestriction() {
    runFeatureTest("piece-deletion-restriction");
  }

  @Test
  @Disabled
  void pieceOperations() {
    runFeatureTest("piece-operations-for-order-flows-mixed-order-line");
  }

  @Test
  void updatePiecesBatchStatus() {
    runFeatureTest("pieces-batch-update-status");
  }

  @Test
  void pieceStatusTransitions() {
    runFeatureTest("piece-status-transitions");
  }

  @Test
  void poLineChangeInstanceConnection() {
    runFeatureTest("poline_change_instance_connection");
  }

  @Test
  void polineClaimingIntervalChecks() {
    runFeatureTest("poline-claiming-interval-checks");
  }

  @Test
  void getPutCompositeOrder() {
    runFeatureTest("productIds-field-error-when-attempting-to-update-unmodified-order");
  }

  @Test
  void receive20Pieces() {
    runFeatureTest("receive-20-pieces");
  }

  @Test
  void receivePieceAgainstNonPackagePol() {
    runFeatureTest("receive-piece-against-non-package-pol");
  }

  @Test
  void receivePieceAgainstPackagePol() {
    runFeatureTest("receive-piece-against-package-pol");
  }

  @Test
  void reopenOrderCreatesEncumbrances() {
    runFeatureTest("reopen-order-creates-encumbrances");
  }

  @Test
  void reopenOrderWith50Lines() {
    runFeatureTest("reopen-order-with-50-lines");
  }

  @Test
  void retrieveTitlesWithHonorOfAcqUnits() {
    runFeatureTest("retrieve-titles-with-honor-of-acq-units");
  }

  @Test
  void routingListPrintTemplate() {
    runFeatureTest("routing-list-print-template");
  }

  @Test
  void testRoutingListApi() {
    runFeatureTest("routing-lists-api");
  }

  @Test
  void shouldDecreaseQuantityWhenDeletePieceWithNoLocation() {
    runFeatureTest("should-decrease-quantity-when-delete-piece-with-no-location");
  }

  @Test
  void threeFundDistributions() {
    runFeatureTest("three-fund-distributions");
  }

  @Test
  void testTitleInstanceCreation() {
    runFeatureTest("title-instance-creation");
  }

  @Test
  void unlinkTitle() {
    runFeatureTest("unlink-title");
  }

  @Test
  void unOpenOrderWithDifferentFund() {
    runFeatureTest("unopen-order-with-different-fund", THREAD_COUNT);
  }

  @Test
  void unreceivePieceAndCheckOrderLine() {
    runFeatureTest("unreceive-piece-and-check-order-line", THREAD_COUNT);
  }

  @Test
  void updateFieldsInItemAfterUpdatingInPiece() {
    runFeatureTest("update_fields_in_item", THREAD_COUNT);
  }

  @Test
  void updatePurchaseOrderWithOrderLines() {
    runFeatureTest("update-purchase-order-with-order-lines");
  }

  @Test
  void updatePurchaseOrderWorkflowStatus() {
    runFeatureTest("update-purchase-order-workflow-status");
  }

  @Test
  void validateFundDistributionForZeroPrice() {
    runFeatureTest("validate-fund-distribution-for-zero-price", THREAD_COUNT);
  }

  @Test
  void validatePoLineReceiptNotRequiredWithCheckinItems() {
    runFeatureTest("validate-pol-receipt-not-required-with-checkin-items");
  }

  @Test
  void createOrderWithSuppressInstanceFromDiscovery() {
    runFeatureTest("create-order-with-suppress-instance-from-discovery");
  }
}
