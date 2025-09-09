Feature: cross-module integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testcross' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/cross-modules/init-cross-modules.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Approve an invoice using different fiscal years
    * call read('features/approve-invoice-using-different-fiscal-years.feature')

  Scenario: Approve invoice with negative line
    * call read('features/approve-invoice-with-negative-line.feature')

  Scenario: Audit events for Invoice
    * call read('features/audit-event-invoice.feature')

  Scenario: Audit events for Invoice Line
    * call read('features/audit-event-invoice-line.feature')

  Scenario: Audit events for Organization
    * call read('features/audit-event-organization.feature')

  Scenario: Cancel invoice and unrelease 2 encumbrances
    * call read('features/cancel-invoice-and-unrelease-2-encumbrances.feature')

  Scenario: Cancel invoice
    * call read('features/cancel-invoice-linked-to-order.feature')

  Scenario: Cancel an invoice with an Encumbrance
    * call read('features/cancel-invoice-with-encumbrance.feature')

  Scenario: Change fund distribution and check initial amount encumbered
    * call read('features/change-fd-check-initial-amount.feature')

  Scenario: Change poline fund distribution and pay invoice
    * call read('features/change-poline-fd-and-pay-invoice.feature')

  Scenario: Check approve and pay invoice with more than 15 invoice lines, several of which reference to same POL
    * call read('features/check-approve-and-pay-invoice-with-invoice-references-same-po-line.feature')

  Scenario: Check encumbrance status after moving expended value
    * call read('features/check-encumbrance-status-after-moving-expended-value.feature')

  Scenario: Check the encumbrances after issuing credit when the order is fully paid
    * call read('features/check-encumbrances-after-issuing-credit-for-paid-order.feature')

  Scenario: Check encumbrances after order is reopened
    * call read('features/check-encumbrances-after-order-is-reopened.feature')

  Scenario: Check encumbrances after order is reopened - 2
    * call read('features/check-encumbrances-after-order-is-reopened-2.feature')

  Scenario: Check encumbrances after order line exchange rate update
    * call read('features/check-encumbrances-after-order-line-exchange-rate-update.feature')

  Scenario: Check order re-encumber after preview rollover
    * call read('features/check-order-re-encumber-after-preview-rollover.feature')

  Scenario: Check order re-encumber works correctly
    * call read('features/check-order-re-encumber-work-correctly.feature')

  Scenario: Check that order total fields are calculated correctly
    * call read('features/check-order-total-fields-calculated-correctly.feature')

  Scenario: Check payment status after cancelling paid invoice
    * call read('features/check-payment-status-after-cancelling-paid-invoice.feature')

  Scenario: Check paymentStatus after reopen
    * call read('features/check-paymentstatus-after-reopen.feature')

  Scenario: Check poNumbers updates
    * call read('features/check-po-numbers-updates.feature')

  Scenario: Check po numbers updates when invoice line deleted
    * call read('features/check-po-numbers-updates-when-invoice-line-deleted.feature')

  Scenario: Create order and approve invoice were pol without fund distributions
    * call read('features/create-order-and-approve-invoice-were-pol-without-fund-distributions.feature')

  Scenario: Create order and invoice with odd penny
    * call read('features/create-order-and-invoice-with-odd-penny.feature')

  Scenario: Create order with invoice that have enough money in budget
    * call read('features/create-order-with-invoice-that-has-enough-money.feature')

  Scenario: Test deleting an encumbrance
    * call read('features/delete-encumbrance.feature')

  Scenario: Invoice encumbrance update without acquisition unit
    * call read('features/invoice-encumbrance-update-without-acquisition-unit.feature')

  Scenario: Test ledger rollover
    * call read('features/ledger-fiscal-year-rollover.feature')

  Scenario: Test ledger fiscal year rollover based on cash balance value
    * call read('features/ledger-fiscal-year-rollover-cash-balance.feature')

  Scenario: Link invoice line to po line
    * call read('features/link-invoice-line-to-po-line.feature')

  Scenario: Delete planned budget without transactions
    * call read('features/MODFISTO-270-delete-planned-budget-without-transactions.feature')

  Scenario: Moving encumbered value from budget 1 to budget 2
    * call read('features/moving_encumbered_value_to_different_budget.feature')

  Scenario: Moving expended amount when editing fund distribution for POL
    * call read('features/moving_expended_value_to_newly_created_encumbrance.feature')

  Scenario: Approve and pay order with 50 lines
    * call read('features/open-approve-and-pay-order-with-50-lines.feature')

  Scenario: Open order after approving invoice
    * call read('features/open-order-after-approving-invoice.feature')

  Scenario: Order-invoice relation
    * call read('features/order-invoice-relation.feature')

  Scenario: Test order invoice relation can be changed
    * call read('features/order-invoice-relation-can-be-changed.feature')

  Scenario: Test order invoice relation can be deleted
    * call read('features/order-invoice-relation-can-be-deleted.feature')

  Scenario: When invoice is deleted, then order vs invoice relation must be deleted and POL can be deleted
    * call read('features/order-invoice-relation-must-be-deleted-if-invoice-deleted.feature')

  Scenario: Partial rollover
    * call read('features/partial-rollover.feature')

  Scenario: Pay an invoice and delete a piece
    * call read('features/pay-invoice-and-delete-piece.feature')

  Scenario: Pay invoice with new expense class
    * call read('features/pay-invoice-with-new-expense-class.feature')

  Scenario: Pay invoice without order acq unit permission
    * call read('features/pay-invoice-without-order-acq-unit-permission.feature')

  Scenario: Pending payment update after encumbrance deletion
    * call read('features/pending-payment-update-after-encumbrance-deletion.feature')

  Scenario: Remove fund distribution after rollover from open order with re-encumber flag is false
    * call read('features/remove-fund-distribution-after-rollover-when-re-encumber-false.feature')

  Scenario: Update linked invoice lines fund distribution reference when update POL
    * call read('features/remove_linked_invoice_lines_fund_distribution_encumbrance_reference.feature')

  Scenario: Rollover and pay invoice using past fiscal year
    * call read('features/rollover-and-pay-invoice-using-past-fiscal-year.feature')

  Scenario: Rollover with closed order
    * call read('features/rollover-with-closed-order.feature')

  Scenario: Rollover with no settings
    * call read('features/rollover-with-no-settings.feature')

  Scenario: Rollover with pending order
    * call read('features/rollover-with-pending-order.feature')

  Scenario: Unopen order, approve invoice and reopen
    * call read('features/unopen-approve-invoice-reopen.feature')

  Scenario: Unopen order and add addition pol and check encumbrances
    * call read('features/unopen-order-and-add-addition-pol-and-check-encumbrances.feature')

  Scenario: Unopen order simple case
    * call read('features/unopen-order-simple-case.feature')

  Scenario: Update encumbrance links with fiscal year
    * call read('features/update-encumbrance-links-with-fiscal-year.feature')

  Scenario: Update fund in poLine when invoice approved
    * call read('features/update_fund_in_poline_when_invoice_approved.feature')

  Scenario: Encumbrance Calculated Correctly For Unopened Ongoing Order
    * call read('features/encumbrance-calculated-correctly-for-unopened-ongoing-order-with-approved-invoice.feature')

  Scenario: Encumbrance Remains 0 For 0 Dollar Ongoing Order After Canceling Paid Invoice Unreleasing Encumbrance And Canceling Another Paid Invoice
    * call read('features/encumbrance-remains-0-for-0-dollar-ongoing-order-after-canceling-paid-invoice-unreleasing-encumbrance-and-canceling-another-paid-invoice.feature')
