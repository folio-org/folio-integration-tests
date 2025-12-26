@parallel=false
Feature: mod-orders integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testorders' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/mod-orders/init-orders.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Auto populate fund code if it missed
    * call read("features/auto-populate-fund-code.feature")

  Scenario: Verify Bind Piece feature
    * call read('features/bind-piece.feature')

  Scenario: Cancel and delete order
    * call read('features/cancel-and-delete-order.feature')

  Scenario: Cancel poLine in multi-line order
    * call read('features/cancel-item-after-canceling-poline-in-multi-line-orders.feature')

  Scenario: Cancel order
    * call read('features/cancel-order.feature')

  Scenario: Change location when receiving a piece
    * call read('features/change-location-when-receiving-piece.feature')

  Scenario: Change Order Instance Connection
    * call read('features/change-order-instance-connection.feature')

  Scenario: Change pending distribution with inactive budget
    * call read('features/change-pending-distribution-with-inactive-budget.feature')

  Scenario: Check estimated price with composite order
    * call read('features/check-estimated-price-with-composite-order.feature')

  Scenario: Check holding instance creation with createInventory options
    * call read('features/check-holding-instance-creation-with-createInventory-options.feature')

  Scenario: Check new tags created in central tag repository
    * call read('features/check-new-tags-in-central-tag-repository.feature')

  @ignore
  Scenario: Check order lines number retrieve limit
    * call read('features/check-order-lines-number-retrieve-limit.feature')

  Scenario: Check needReEncumber flag populated correctly
    * call read('features/check-re-encumber-property.feature')

  Scenario: Close order and release encumbrances
    * call read('features/close-order-and-release-encumbrances.feature')

  Scenario: Close order including lines
    * call read('features/close-order-including-lines.feature')

  Scenario: Close order when fully paid and received
    * call read('features/close-order-when-fully-paid-and-received.feature')

  Scenario: Create fives pieces for an open order
    * call read('features/create-five-pieces.feature')

  Scenario: Create Order Check Items
    * call read('features/create-order-check-items.feature')

  Scenario: Create open composite order
    * call read('features/create-open-composite-order.feature')

  Scenario: Create order that has not enough money
    * call read('features/create-order-that-has-not-enough-money.feature')

  Scenario: Create Order Payment Not Required Fully Receive
    * call read('features/create-order-payment-not-required-fully-receive.feature')

  Scenario: Create order with suppress instance from discovery
    * call read("features/create-order-with-suppress-instance-from-discovery.feature")

  Scenario: Delete fund distribution
    * call read('features/delete-fund-distribution.feature')

  Scenario: Delete One Piece In Receiving
    * call read('features/delete-one-piece-in-receiving.feature')

  Scenario: Delete opened order and order lines
    * call read('features/delete-opened-order-and-lines.feature')

  Scenario: Encumbrance released when order closes
    * call read('features/encumbrance-released-when-order-closes.feature')

  Scenario: Encumbrance tags inheritance
    * call read('features/encumbrance-tags-inheritance.feature')

  Scenario: Encumbrance update after expense class change
    * call read('features/encumbrance-update-after-expense-class-change.feature')

  Scenario: Handling of expense classes for order and lines
    * call read('features/expense-class-handling-for-order-and-lines.feature')

  Scenario: Find holdings by location and instance for mixed pol
    * call read('features/find-holdings-by-location-and-instance-for-mixed-pol.feature')

  Scenario: Fund codes in open order error
    * call read('features/fund-codes-in-open-order-error.feature')

  Scenario: Increase poline quantity for open order
    * call read('features/increase-poline-quantity-for-open-order.feature')

  Scenario: Independent acquisitions unit for ordering and receiving
    * call read('features/independent-acquisitions-unit-for-ordering-and-receiving.feature')

  Scenario: Check Items and holding process
    * call read('features/item-and-holding-operations-for-order-flows.feature')

  Scenario: Should create and delete pieces for non package mixed POL with quantity POL updates and manual piece is false
    * call read('features/MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false.feature')

  Scenario: Should create and delete pieces for non package mixed POL with quantity POL updates and manual piece is true
    * call read('features/MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true.feature')

  Scenario: Update piece against non package mixed pol manual piece creation is false
    * call read('features/MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false.feature')

  Scenario: Should update location in the POL if change Location to a different holding on that instance for piece
    * call read('features/MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package.feature')

  Scenario: If I don't choose to create an item when creating the piece. If I edit that piece and select create item the item must created
    * call read('features/MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item.feature')

  Scenario: Move Item and Holding to update order data
    * call read('features/move-item-and-holding-to-update-order-data.feature')

  Scenario: Open and unopen order
    * call read('features/open-and-unopen-order.feature')

  Scenario: Open ongoing order
    * call read('features/open-ongoing-order.feature')

  Scenario: Open Ongoing order if interval or renewaldate notset
    * call read('features/open-ongoing-order-if-interval-or-renewaldate-notset.feature')

  Scenario: Open order failure side effects
    * call read('features/open-order-failure-side-effects.feature')

  Scenario: Check opening an order links to the right instance
    * call read('features/open-order-instance-link.feature')

  Scenario: Open order success with expenditure restrictions
    * call read('features/open-order-success-with-expenditure-restrictions.feature')

  Scenario: Open Orders with PoLines
    * call read('features/open-orders-with-poLines.feature')

  Scenario: Open order with different po line currency
    * call read('features/open-order-with-different-po-line-currency.feature')

  Scenario: Open order with manual exchange rate
    * call read('features/open-order-with-manual-exchange-rate.feature')

  Scenario: Open order with many Product IDs
    * call read('features/open-order-with-many-product-ids.feature')

  Scenario: Open order without holdings
    * call read('features/open-order-without-holdings.feature')

  Scenario: Open order with resolution po line statuses
    * call read('features/open-order-with-resolution-statuses.feature')

  Scenario: Open order with restricted locations
    * call read('features/open-order-with-restricted-locations.feature')

  Scenario: Should open order with polines having the same fund distributions
    * call read('features/open-order-with-the-same-fund-distributions.feature')

  Scenario: Retrieve Order Events
    * call read('features/order-event.feature')

  Scenario: Retrieve OrderLine Events
    * call read('features/order-line-event.feature')

  Scenario: Create pieces for an open order in parallel
    * call read('features/parallel-create-piece.feature')

  Scenario: Update order lines for different open orders in parallel (using the same fund), and check budget
    * call read('features/parallel-update-order-lines-different-orders.feature')

  Scenario: Update order lines for the same open orders in parallel
    * call read('features/parallel-update-order-lines-same-order.feature')

  Scenario: P/E mix update piece
    * call read('features/pe-mix-update-piece.feature')

  Scenario: Piece audit history
    * call read('features/piece-audit-history.feature')

  Scenario: Piece batch job testing
    * call read('features/piece-batch-job.feature')

  Scenario: Piece deletion restrictions from order and order line
    * call read('features/piece-deletion-restriction.feature')

# Need to revise cases again, because almost of them was covered in the another features.
# Also need better to split feature between package and non-package
  @ignore
  Scenario: Piece operations
    * call read('features/piece-operations-for-order-flows-mixed-order-line.feature')

  Scenario: Update Pieces statuses in batch
    * call read('features/pieces-batch-update-status.feature')

  Scenario: Piece sequence numbers
    * call read('features/piece-sequence-numbers.feature')

  Scenario: Piece status transitions
    * call read('features/piece-status-transitions.feature')

  Scenario: PoLine change instance connection
    * call read('features/poline_change_instance_connection.feature')

  Scenario: PoLine change instance connection with holdings and items
    * call read('features/poline-change-instance-connection-with-holdings-items.feature')

  Scenario: Claiming Active/Claiming interval checks
    * call read('features/poline-claiming-interval-checks.feature')

  Scenario: Update pending order with new productIds
    * call read('features/productIds-field-error-when-attempting-to-update-unmodified-order.feature')

  Scenario: Receive 20 pieces
    * call read('features/receive-20-pieces.feature')

  Scenario: Receive piece against non-package POL
    * call read('features/receive-piece-against-non-package-pol.feature')

  Scenario: Receive piece against package POL
    * call read('features/receive-piece-against-package-pol.feature')

  Scenario: Reopen an order creates encumbrances
    * call read('features/reopen-order-creates-encumbrances.feature')

  Scenario: Receive piece in new holding
    * call read('features/receive-piece-new-holding-edit.feature')

  Scenario: Reopen order with 50 lines
    * call read('features/reopen-order-with-50-lines.feature')

  Scenario: Retrieve titles with honor of acquisition units
    * call read('features/retrieve-titles-with-honor-of-acq-units.feature')

  Scenario: Check processing of printing routing list functionality
    * call read('features/routing-list-print-template.feature')

  Scenario: Test routing list API
    * call read('features/routing-lists-api.feature')

  Scenario: Should decrease quantity when delete piece with no location
    * call read('features/should-decrease-quantity-when-delete-piece-with-no-location.feature')

  Scenario: Three fund distributions
    * call read('features/three-fund-distributions.feature')

  Scenario: Title instance creation
    * call read('features/title-instance-creation.feature')

  Scenario: Unlink title
    * call read('features/unlink-title.feature')

  Scenario: Unopen order and change fund distribution
    * call read('features/unopen-order-with-different-fund.feature')

  Scenario: Unreceive a piece and check the order line
    * call read('features/unreceive-piece-and-check-order-line.feature')

  Scenario: Update fields in item after updating in piece
    * call read('features/update_fields_in_item.feature')

  Scenario: Update purchase order with order lines
    * call read('features/update-purchase-order-with-order-lines.feature')

  Scenario: Update purchase order workflow status
    * call read('features/update-purchase-order-workflow-status.feature')

  Scenario: Validate fund distribution for zero price
    * call read('features/validate-fund-distribution-for-zero-price.feature')
