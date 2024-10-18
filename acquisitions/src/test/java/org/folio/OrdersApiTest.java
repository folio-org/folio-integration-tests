package org.folio;

import org.folio.test.TestBase;
import org.folio.test.annotation.FolioTest;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

@FolioTest(team = "thunderjet", module = "mod-orders")
public class OrdersApiTest extends TestBase {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:thunderjet/mod-orders/features/";
  private static final int THREAD_COUNT = 4;

  public OrdersApiTest() {
    super(new TestIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void changeLocationWhenReceivingPiece() {
    runFeatureTest("change-location-when-receiving-piece");
  }

  @Test
  void deleteFundDistribution() {
    runFeatureTest("delete-fund-distribution");
  }

  @Test
  void deleteOpenedOrderAndOrderLines() {
    runFeatureTest("delete-opened-order-and-lines.feature");
  }

  @Test
  void closeOrderWhenFullyPaidAndReceived() {
    runFeatureTest("close-order-when-fully-paid-and-received");
  }

  @Test
  void createOrderWithNotEnoughMoney() {
    runFeatureTest("create-order-that-has-not-enough-money");
  }

  @Test
  void encumbranceTagsInheritance() {
    runFeatureTest("encumbrance-tags-inheritance");
  }

  @Test
  void expenseClassHandlingOrderWithLines() {
    runFeatureTest("expense-class-handling-for-order-and-lines");
  }

  @Test
  void increasePolineQuantityOpenOrder() {
    runFeatureTest("increase-poline-quantity-for-open-order");
  }

  @Test
  void openOrderWithDifferentPoLineCurrency() {
    runFeatureTest("open-order-with-different-po-line-currency");
  }

  @Test
  void checkOrderNeedReEncumber() {
    runFeatureTest("check-re-encumber-property");
  }

  @Test
  void openOrderWithManualExchangeRate() {
    runFeatureTest("open-order-with-manual-exchange-rate");
  }


  @Test
  void checkOrderReEncumberWorksCorrectly() {
    runFeatureTest("check-order-re-encumber-work-correctly");
  }

  @Test
  void openOngoingOrder() {
    runFeatureTest("open-ongoing-order");
  }

  @Test
  void openOrderWithRestrictedLocations() {
    runFeatureTest("open-order-with-restricted-locations");
  }

  @Disabled
  @Test
  void checkOrderLinesNumberRetrieveLimit() {
    runFeatureTest("check-order-lines-number-retrieve-limit");
  }

  @Test
  void checkNewTagsCreatedInCentralTagRepository() {
    runFeatureTest("check-new-tags-in-central-tag-repository");
  }

  @Test
  void closeOrderAndReleaseEncumbrances() {
    runFeatureTest("close-order-and-release-encumbrances");
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
  void openOrderWithoutHoldings() {
    runFeatureTest("open-order-without-holdings");
  }

  @Test
  void openOrderWithTheSameFundDistributions() {
    runFeatureTest("open-order-with-the-same-fund-distributions");
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
  void parallelUpdateOrderLinesDifferentOrders() {
    runFeatureTest("parallel-update-order-lines-different-orders", 5);
  }

  @Test
  void shouldDecreaseQuantityWhenDeletePieceWithNoLocation() {
    runFeatureTest("should-decrease-quantity-when-delete-piece-with-no-location");
  }

  @Test
  void unopenAndChangeFundDistribution() {
    runFeatureTest("unopen-and-change-fund-distribution", THREAD_COUNT);
  }

  @Test
  void openAndUnopenOrder() {
    runFeatureTest("open-and-unopen-order", THREAD_COUNT);
  }

  @Test
  void unopenAfterAddingTheSameFundDistribution() {
    runFeatureTest("unopen-order-after-adding-the-same-fund-distribution", THREAD_COUNT);
  }

  @Test
  void fundCodesInOpenOrderError() {
    runFeatureTest("fund-codes-in-open-order-error");
  }

  @Test
  void threeFundDistributions() {
    runFeatureTest("three-fund-distributions");
  }

  @Test
  void cancelOrder() {
    runFeatureTest("cancel-order", THREAD_COUNT);
  }

  @Test
  void getPutCompositeOrder() {
    runFeatureTest("productIds-field-error-when-attempting-to-update-unmodified-order");
  }

  @Test
  void createFivePieces() {
    runFeatureTest("create-five-pieces");
  }

  @Test
  void reopenOrderCreatesEncumbrances() {
    runFeatureTest("reopen-order-creates-encumbrances");
  }

  @Test
  void cancelAndDeleteOrder() {
    runFeatureTest("cancel-and-delete-order");
  }

  @Test
  void validateFundDistributionForZeroPrice() {
    runFeatureTest("validate-fund-distribution-for-zero-price", THREAD_COUNT);
  }

  @Disabled
  @Test
  void pieceOperations() {
    runFeatureTest("piece-operations-for-order-flows-mixed-order-line");
  }

  @Test
  void itemAndHoldingsOperations() { runFeatureTest("item-and-holding-operations-for-order-flows"); }

  @Test
  void retrieveTitlesWithHonorOfAcqUnits() {
    runFeatureTest("retrieve-titles-with-honor-of-acq-units");
  }

  @Test
  void movingEncumberedValueToDifferentBudget() {
    runFeatureTest("moving_encumbered_value_to_different_budget");
  }

  @Test
  void movingExpendedValueToNewlyCreatedEncumbrance() {
    runFeatureTest("moving_expended_value_to_newly_created_encumbrance");
  }

  @Test
  void checkEncumbranceStatusAfterMovingExpendedValue() {
    runFeatureTest("check-encumbrance-status-after-moving-expended-value");
  }

  @Test
  void removeLinkedInvoiceLinesFundDistributionEncumbranceReference() {
    runFeatureTest("remove_linked_invoice_lines_fund_distribution_encumbrance_reference");
  }

  @Test
  void updateFieldsInItemAfterUpdatingInPiece() {
    runFeatureTest("update_fields_in_item", THREAD_COUNT);
  }

  @Test
  void updateFundInPoLineWhenInvoiceApproved() {
    runFeatureTest("update_fund_in_poline_when_invoice_approved");
  }

  @Test
  void orderEventTests() { runFeatureTest("order-event"); }

  @Test
  void orderLineEventTests() { runFeatureTest("order-line-event"); }

  @Test
  void encumbranceReleasedWhenOrderCloses() { runFeatureTest("encumbrance-released-when-order-closes"); }

  @Test
  void receive20Pieces() { runFeatureTest("receive-20-pieces"); }

  @Test
  void reopenOrderWith50Lines() {
    runFeatureTest("reopen-order-with-50-lines");
  }

  @Test
  void closeOrderIncludingLines() {
    runFeatureTest("close-order-including-lines");
  }

  @Test
  void openOrderWithResolutionPoLineStatuses() {
    runFeatureTest("open-order-with-resolution-statuses");
  }

  @Test
  void findHoldingForMixedPol() {
    runFeatureTest("find-holdings-by-location-and-instance-for-mixed-pol");
  }

  @Test
  void findHoldingForMixedPolWithCreateInventoryNone() {
    runFeatureTest("find-holdings-by-location-and-instance-for-mixed-pol-with-create-inventory-none");
  }

  @Test
  void poLineChangeInstanceConnection() {
    runFeatureTest("poline_change_instance_connection");
  }

  @Test
  void unreceivePieceAndCheckOrderLine() {
    runFeatureTest("unreceive-piece-and-check-order-line", THREAD_COUNT);
  }

  @Test
  void independentAcquisitionsUnitForOrderReceiving() {
    runFeatureTest("independent-acquisitions-unit-for-ordering-and-receiving.feature");
  }

  @Test
  void pieceStatusTransitions() {
    runFeatureTest("piece-status-transitions");
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
  void polineClaimingIntervalChecks() {
    runFeatureTest("poline-claiming-interval-checks");
  }

  @Test
  void openApproveAndPayOrderWith50Lines() {runFeatureTest("open-approve-and-pay-order-with-50-lines.feature");}

  @Test
  void parallelCreatePiece() {
    runFeatureTest("parallel-create-piece", 5);
  }

  @Test
  void parallelUpdateOrderLinesSameOrder() {
    runFeatureTest("parallel-update-order-lines-same-order", 5);
  }

  @Test
  void encumbranceUpdateAfterExpenseClassChange() {
    runFeatureTest("encumbrance-update-after-expense-class-change");
  }

  @Test
  void openOrderSuccessWithExpenditureRestrictions() {
    runFeatureTest("open-order-success-with-expenditure-restrictions");
  }

  @Test
  void testRoutingListApi() {
    runFeatureTest("routing-lists-api");
  }

  @Test
  void testTitleInstanceCreation() {
    runFeatureTest("title-instance-creation");
  }

  @Test
  void routingListPrintTemplate() {
    runFeatureTest("routing-list-print-template.feature");
  }

  @Test
  void peMixUpdatePiece() {
    runFeatureTest("pe-mix-update-piece");
  }

  @Test
  void checkEstimatedPriceWithCompositeOrder() {
    runFeatureTest("check-estimated-price-with-composite-order");
  }

  @Test
  void createOpenCompositeOrder() {
    runFeatureTest("create-open-composite-order");
  }

  @Test
  void bindPiece() {
    runFeatureTest("bind-piece.feature");
  }

  @Test
  void updatePurchaseOrderWithOrderLines() {
    runFeatureTest("update-purchase-order-with-order-lines.feature");
  }

  @Test
  void updatePurchaseOrderWorkflowStatus() {
    runFeatureTest("update-purchase-order-workflow-status.feature");
  }

  @Test
  void pieceDeletionRestriction() {
    runFeatureTest("piece-deletion-restriction.feature");
  }

  @Test
  void updateInventoryOwnershipChangesOrderData() {
    runFeatureTest("update-inventory-ownership-changes-order-data.feature");
  }

  @BeforeAll
  public void ordersApiTestBeforeAll() {
    runFeature("classpath:thunderjet/mod-orders/orders-junit.feature");
  }

  @AfterAll
  public void ordersApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
