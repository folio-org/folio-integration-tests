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
    runFeatureTest("unopen-and-change-fund-distribution");
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
    runFeatureTest("cancel-order");
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
    runFeatureTest("validate-fund-distribution-for-zero-price");
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
  void updateLinkedInvoiceLinesFundDistributionReference() {
    runFeatureTest("update_linked_invoice_lines_fund_distribution_reference");
  }

  @Test
  void updateFieldsInItemAfterUpdatingInPiece() {
    runFeatureTest("update_fields_in_item");
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

  @BeforeAll
  public void ordersApiTestBeforeAll() {
    runFeature("classpath:thunderjet/mod-orders/orders-junit.feature");
  }

  @AfterAll
  public void ordersApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}
