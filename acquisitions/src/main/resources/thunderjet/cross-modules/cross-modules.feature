Feature: cross-module integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-invoice'       |
      | 'mod-finance'       |
      | 'mod-orders'        |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |
      | 'mod-tags'          |


    * def random = callonce randomMillis
    * def testTenant = 'testcrossmodules' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                                        |
      | 'finance.module.all'                                        |
      | 'finance.all'                                               |
      | 'orders-storage.module.all'                                 |

    * table userPermissions
      | name                       |
      | 'invoice.all'              |
      | 'orders.all'               |
      | 'finance.all'              |
      | 'orders.item.approve'      |
      | 'orders.item.reopen'       |
      | 'orders.item.unopen'       |

    # Looks like already exist, but if not pleas uncomment
    #* table desiredPermissions
    #  | desiredPermissionName |
    #  | 'orders.item.approve' |
    #  | 'orders.item.reopen'  |
    #  | 'orders.item.unopen'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')


  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Approve invoice with negative line
    Given call read('features/approve-invoice-with-negative-line.feature')

  Scenario: Check encumbrances after order is reopened
    Given call read('features/check-encumbrances-after-order-is-reopened.feature')

  Scenario: Check encumbrances after order is reopened - 2
    Given call read('features/check-encumbrances-after-order-is-reopened-2.feature')

  Scenario: Check poNumbers updates
    Given call read('features/check-po-numbers-updates.feature')

  Scenario: create order with invoice that have enough money in budget
    Given call read('features/create-order-with-invoice-that-has-enough-money.feature')

  Scenario: create order and invoice with odd penny
    Given call read('features/create-order-and-invoice-with-odd-penny.feature')

  Scenario: Test deleting an encumbrance
    Given call read('features/delete-encumbrance.feature')

  Scenario: link invoice line to po line
    Given call read('features/link-invoice-line-to-po-line.feature')

  Scenario: order invoice relation
    Given call read('features/order-invoice-relation.feature')

  Scenario: unopen order and add addition pol and check encumbrances
    Given call read('features/unopen-order-and-add-addition-pol-and-check-encumbrances.feature')

  Scenario: unopen order simple case
    Given call read('features/unopen-order-simple-case.feature')

  Scenario: delete planned budget without transactions
    Given call read('features/MODFISTO-270-delete-planned-budget-without-transactions.feature')

  Scenario: create-order-and-approve-invoice-were-pol-without-fund-distributions
    Given call read('features/create-order-and-approve-invoice-were-pol-without-fund-distributions.feature')

  Scenario: order-invoice-relation-can-be-changed
    Given call read('features/order-invoice-relation-can-be-changed.feature')

  Scenario: order-invoice-relation-can-be-deleted
    Given call read('features/order-invoice-relation-can-be-deleted.feature')

  Scenario: order-invoice-relation-must-be-deleted-if-invoice-deleted
    Given call read('features/order-invoice-relation-must-be-deleted-if-invoice-deleted.feature')

  Scenario: Chek po numbers updates when invoice line deleted
    Given call read('features/chek-po-numbers-updates-when-invoice-line-deleted.feature')

  Scenario: Pay invoice with new expense class
    Given call read('features/pay-invoice-with-new-expense-class.feature')

  Scenario: Change poline fund distribution and pay invoice
    Given call read('features/change-poline-fd-and-pay-invoice.feature')

  Scenario: Cancel invoice
    Given call read('features/cancel-invoice-linked-to-order.feature')

  Scenario: Check approve and pay invoice with more than 15 invoice lines, several of which reference to same POL
    Given call read('features/check-approve-and-pay-invoice-with-invoice-references-same-po-line.feature')

  Scenario: Approve an invoice using different fiscal years
    Given call read('features/approve-invoice-using-different-fiscal-years.feature')

  Scenario: Partial rollover
    Given call read('features/partial-rollover.feature')

  Scenario: Cancel invoice and unrelease 2 encumbrances
    Given call read('features/cancel-invoice-and-unrelease-2-encumbrances.feature')

  Scenario: Rollover with closed order
    Given call read('features/rollover-with-closed-order.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
