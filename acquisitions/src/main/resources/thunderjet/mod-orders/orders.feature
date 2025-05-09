Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-tags'                  |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-template-engine'       |
      | 'mod-feesfines'             |

    * def random = callonce randomMillis
    * def testTenant = 'testorders' + random
#    * def testTenant = 'testorders1'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                         |
      | 'orders-storage.module.all'                  |
      | 'finance.module.all'                         |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post'   |
      | 'acquisitions-units.units.item.post'         |


    * table userPermissions
      | name                                        |
      | 'orders.all'                                |
      | 'finance.all'                               |
      | 'inventory.all'                             |
      | 'invoice.all'                               |
      | 'tags.all'                                  |
      | 'audit.all'                                 |
      | 'orders.item.approve'                       |
      | 'orders.item.reopen'                        |
      | 'orders.item.unopen'                        |
      | 'orders-storage.claiming.process.execute'   |
      | 'inventory-storage.holdings.collection.get' |
      | 'inventory-storage.instances.item.get'      |
      | 'inventory-storage.items.collection.get'    |

# Looks like already exist, but if not pleas uncomment
#    * table desiredPermissions
#      | desiredPermissionName |
#      | 'orders.item.approve' |
#      | 'orders.item.reopen'  |
#      | 'orders.item.unopen'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/orders.feature')

  Scenario: Change location when receiving a piece
    Given call read('features/change-location-when-receiving-piece.feature')

  Scenario: Delete fund distribution
    Given call read('features/delete-fund-distribution.feature')

  Scenario: Delete opened order and order lines
    Given call read('features/delete-opened-order-and-lines.feature')

  Scenario: Increase poline quantity for open order
    Given call read('features/increase-poline-quantity-for-open-order.feature')

  Scenario: Close order when fully paid and received
    Given call read('features/close-order-when-fully-paid-and-received.feature')

  Scenario: Handling of expense classes for order and lines
    Given call read('features/expense-class-handling-for-order-and-lines.feature')

  Scenario: Create order that has not enough money
    Given call read('features/create-order-that-has-not-enough-money.feature')

  Scenario: Encumbrance tags inheritance
    Given call read('features/encumbrance-tags-inheritance.feature')

  Scenario: Open order with different po line currency
    Given call read('features/open-order-with-different-po-line-currency.feature')

  Scenario: Check needReEncumber flag populated correctly
    Given call read('features/check-re-encumber-property.feature')

#  Scenario: Check order lines number retrieve limit
#    Given call read('features/check-order-lines-number-retrieve-limit.feature')

  Scenario: Check totalEncumbered and totalExpended calculated correctly
    Given call read('features/check_total_encumbered_expended_calculated_correctly.feature')

  Scenario: Open order with manual exchange rate
    Given call read('features/open-order-with-manual-exchange-rate.feature')

  Scenario: Check order re-encumber works correctly
    Given call read('features/check-order-re-encumber-work-correctly.feature')

  Scenario: Open ongoing order
    Given call read('features/open-ongoing-order.feature')

  Scenario: Open order with restricted locations
    Given call read('features/open-order-with-restricted-locations.feature')

  Scenario: Close order and release encumbrances
    Given call read('features/close-order-and-release-encumbrances.feature')

  Scenario: Check new tags created in central tag repository
    Given call read('features/check-new-tags-in-central-tag-repository.feature')

  Scenario: Open Ongoing order if interval or renewaldate notset
    Given call read('features/open-ongoing-order-if-interval-or-renewaldate-notset.feature')

  Scenario: Open order failure side effects
    Given call read('features/open-order-failure-side-effects.feature')

  Scenario: Check opening an order links to the right instance
    Given call read('features/open-order-instance-link.feature')

  Scenario: Open order without holdings
    Given call read('features/open-order-without-holdings.feature')

  Scenario: Should open order with polines having the same fund distributions
    Given call read('features/open-order-with-the-same-fund-distributions.feature')

  Scenario: Receive piece against non-package POL
    Given call read('features/receive-piece-against-non-package-pol.feature')

  Scenario: Receive piece against package POL
    Given call read('features/receive-piece-against-package-pol.feature')

  Scenario: Should create and delete pieces for non package mixed POL with quantity POL updates and manual piece is false
    Given call read("features/MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-false.feature")

  Scenario: Should create and delete pieces for non package mixed POL with quantity POL updates and manual piece is true
    Given call read("features/MODORDERS-538-piece-against-non-package-mixed-pol-manual-piece-creation-is-true.feature")

  Scenario: Update piece against non package mixed pol manual piece creation is false
    Given call read("features/MODORDERS-579-update-piece-against-non-package-mixed-pol-manual-piece-creation-is-false.feature")

  Scenario: Should update location in the POL if change Location to a different holding on that instance for piece
    Given call read("features/MODORDERS-580-update-piece-POL-location-not-updated-when-piece-location-edited-against-non-package.feature")

  Scenario: If I don't choose to create an item when creating the piece. If I edit that piece and select create item the item must created
    Given call read("features/MODORDERS-583-add-piece-without-item-then-open-to-update-and-set-create-item.feature")

# Need to revise cases again, because almost of them was covered in the another features.
# Also need better to split feature between package and non-package
#  Scenario: Piece operations
#    Given call read('features/piece-operations-for-order-flows-mixed-order-line.feature')

  Scenario: Should decrease quantity when delete piece with no location
    Given call read("features/should-decrease-quantity-when-delete-piece-with-no-location.feature")

  Scenario: Fund codes in open order error
    Given call read("features/fund-codes-in-open-order-error.feature")

  Scenario: Three fund distributions
    Given call read("features/three-fund-distributions.feature")

  Scenario: Cancel order
    Given call read("features/cancel-order.feature")

  Scenario: Cancel poLine in multi-line order
    Given call read("features/cancel-item-after-canceling-poline-in-multi-line-orders.feature")

  Scenario: Update fund in poLine when invoice approved
    Given call read("features/update_fund_in_poline_when_invoice_approved.feature")

  Scenario: Moving encumbered value from budget 1 to budget 2
    Given call read("features/moving_encumbered_value_to_different_budget.feature")

  Scenario: Moving expended amount when editing fund distribution for POL
    Given call read("features/moving_expended_value_to_newly_created_encumbrance.feature.feature")

  Scenario: Check encumbrance status after moving expended value
    Given call read("features/check-encumbrance-status-after-moving-expended-value.feature")

  Scenario: Update linked invoice lines fund distribution reference when update POL
    Given call read("features/remove_linked_invoice_lines_fund_distribution_encumbrance_reference.feature")

  Scenario: Update fields in item after updating in piece
    Given call read("features/update_fields_in_item.feature")

  Scenario: Create fives pieces for an open order
    Given call read("features/create-five-pieces.feature")

  Scenario: Reopen an order creates encumbrances
    Given call read("features/reopen-order-creates-encumbrances.feature")

  Scenario: Cancel and delete order
    Given call read("features/cancel-and-delete-order.feature")

  Scenario: Validate fund distribution for zero price
    Given call read("features/validate-fund-distribution-for-zero-price.feature")

  Scenario: Update pending order with new productIds
    Given call read("features/productIds-field-error-when-attempting-to-update-unmodified-order.feature")

  Scenario: Retrieve titles with honor of acquisition units
    Given call read("features/retrieve-titles-with-honor-of-acq-units.feature")

  Scenario: Retrieve Order Events
    Given call read("features/order-event.feature")

  Scenario: Retrieve OrderLine Events
    Given call read("features/order-line-event.feature")

  Scenario: Encumbrance released when order closes
    Given call read("features/encumbrance-released-when-order-closes.feature")

  Scenario: Receive 20 pieces
    Given call read("features/receive-20-pieces.feature")

  Scenario: Reopen order with 50 lines
    Given call read("features/reopen-order-with-50-lines.feature")

  Scenario: Close order including lines
    Given call read("features/close-order-including-lines.feature")

  Scenario: Open order with resolution po line statuses
    Given call read("features/open-order-with-resolution-statuses.feature")

  Scenario: Find holdings by location and instance for mixed pol
    Given call read("features/find-holdings-by-location-and-instance-for-mixed-pol.feature")

  Scenario: PoLine change instance connection
    Given call read("features/poline_change_instance_connection.feature")

  Scenario: Piece status transitions
    Given call read("features/piece-status-transitions.feature")

  Scenario: Piece audit history
    Given call read("features/piece-audit-history.feature")

  Scenario: Piece batch job testing
    Given call read("features/piece-batch-job.feature")

  Scenario: Claiming Active/Claiming interval checks
    Given call read("features/poline-claiming-interval-checks.feature")

  Scenario: Unreceive a piece and check the order line
    Given call read("features/unreceive-piece-and-check-order-line.feature")

  Scenario: Encumbrance update after expense class change
    Given call read("features/encumbrance-update-after-expense-class-change.feature")

  Scenario: Open order success with expenditure restrictions
    Given call read("features/open-order-success-with-expenditure-restrictions.feature")

  Scenario: Test routing list API
    Given call read("features/routing-lists-api.feature")

  Scenario: P/E mix update piece
    Given call read("features/pe-mix-update-piece.feature")

  Scenario: Title instance creation
    Given call read("features/title-instance-creation.feature")

  Scenario: Check estimated price with composite order
    Given call read("features/check-estimated-price-with-composite-order.feature")

  Scenario: Create open composite order
    Given call read("features/create-open-composite-order.feature")

  Scenario: Update inventory ownership changes order data
    Given call read("features/update-inventory-ownership-changes-order-data.feature")

  Scenario: Update Pieces statuses in batch
    Given call read("features/pieces-batch-update-status.feature")

  Scenario: Open Orders with PoLines
    Given call read("features/open-orders-with-poLines.feature")

  Scenario: Change pending distribution with inactive budget
    Given call read("features/change-pending-distribution-with-inactive-budget.feature")

  # These 2 have to be called with OrdersApiTest - this comment is here as a reminder
  #  Scenario: Create pieces for an open order in parallel
  #    Given call read("features/parallel-create-piece.feature")
  #  Scenario: Update order lines for the same open orders in parallel
  #    Given call read("features/parallel-update-order-lines-same-order.feature")
  Scenario: Unlink title
    Given call read("features/unlink-title.feature")

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
