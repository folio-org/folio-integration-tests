Feature: cross-module integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations-storage' |


    * def random = callonce randomMillis
    * def testTenant = 'testcrossmodules' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                         |
      | 'finance.module.all'                         |
      | 'finance.all'                                |
      | 'orders-storage.module.all'                  |
      | 'acquisitions-units.memberships.item.delete' |

    * table userPermissions
      | name                                  |
      | 'invoice.all'                         |
      | 'orders.all'                          |
      | 'finance.all'                         |
      | 'orders.item.approve'                 |
      | 'orders.item.reopen'                  |
      | 'orders.item.unopen'                  |
      | 'invoices.fiscal-year.update.execute' |
      | 'invoice.item.approve.execute'        |
      | 'invoice.item.pay.execute'            |
      | 'invoice.item.cancel.execute'         |

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

  Scenario: Pay an invoice and delete a piece
    Given call read('features/pay-invoice-and-delete-piece.feature')

  Scenario: Unopen order, approve invoice and reopen
    Given call read('features/unopen-approve-invoice-reopen.feature')

  Scenario: Change fund distribution and check initial amount encumbered
    Given call read('features/change-fd-check-initial-amount.feature')

  Scenario: Open order after approving invoice
    Given call read('features/open-order-after-approving-invoice.feature')

  Scenario: Update encumbrance links with fiscal year
    Given call read('features/update-encumbrance-links-with-fiscal-year.feature')

  Scenario: Check order re-encumber after preview rollover
    Given call read('features/check-order-re-encumber-after-preview-rollover.feature')

  Scenario: Pending payment update after encumbrance deletion
    Given call read('features/pending-payment-update-after-encumbrance-deletion.feature')

  Scenario: Remove fund distribution after rollover from open order with re-encumber flag is false
    Given call read('features/remove-fund-distribution-after-rollover-when-re-encumber-false.feature')

  Scenario: Pay invoice without order acq unit permission
    Given call read('features/pay-invoice-without-order-acq-unit-permission.feature')

  Scenario: Check paymentStatus after reopen
    Given call read('features/check-paymentstatus-after-reopen.feature')

  Scenario: Invoice encumbrance update without acquisition unit
    Given call read('features/invoice-encumbrance-update-without-acquisition-unit.feature')

  Scenario: Check payment status after cancelling paid invoice
    Given call read('features/check-payment-status-after-cancelling-paid-invoice.feature')

  Scenario: Check the encumbrances after issuing credit when the order is fully paid
    Given call read('features/check-encumbrances-after-issuing-credit-for-paid-order.feature')

  Scenario: Approve or cancel an invoice with the poLinePaymentStatus parameter
    Given call read('features/approve-or-cancel-invoice-with-polinepaymentstatus-parameter.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
