Feature: mod-invoice integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testinvoice' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/mod-invoice/init-invoice.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Approve and pay invoice with past fiscal year
    * call read('features/approve-and-pay-invoice-with-past-fiscal-year.feature')

  Scenario: Batch voucher export with many lines
    * call read('features/batch-voucher-export-with-many-lines.feature')

  Scenario: Check vendor address included with batch voucher
    * call read('features/batch-voucher-uploaded.feature')

  Scenario: Cancel invoice
    * call read('features/cancel-invoice.feature')

  Scenario: Check approve and pay invoice with odd number of pennies in total
    * call read('features/check-approve-and-pay-invoice-with-odd-pennies-number.feature')

  Scenario: Check approve and pay invoice with 0$ amount
    * call read('features/check-approve-and-pay-invoice-with-zero-dollar-amount.feature')

  Scenario: Check that error response should have fundcode included when when there is not enough budget
    * call read('features/check-error-respose-with-fundcode-upon-invoice-approval.feature')

  Scenario: Check invoice and invoice lines deletion restrictions
    * call read('features/check-invoice-and-invoice-lines-deletion-restrictions.feature')

  Scenario: Check invoice full flow where sub total is negative
    * call read('features/check-invoice-full-flow-where-subTotal-is-negative.feature')

  Scenario: Check invoice lines and documents are deleted with invoice
    * call read('features/check-invoice-lines-and-documents-are-deleted-with-invoice.feature')

  Scenario: Check invoice line with VAT adjustments
    * call read('features/check-invoice-lines-with-vat-adjustments.feature')

  Scenario: Check invoiceLine validation with  adjustments
    * call read('features/check-invoice-line-validation-with-adjustments.feature')

  Scenario: Check invoice approve flow if lockTotal is specified
    * call read('features/check-lock-totals-and-calculated-totals-in-invoice-approve-time.feature')

  Scenario: Check remaining amount upon invoice approval
    * call read('features/check-remaining-amount-upon-invoice-approval.feature')

  Scenario: Check that can not approve invoice if organization is not vendor
    * call read('features/check-that-can-not-approve-invoice-if-organization-is-not-vendor.feature')

  Scenario: Checking that it is impossible to pay for the invoice if no voucher for invoice
    * call read('features/check-that-changing-protected-fields-forbidden-for-approved-invoice.feature')

  Scenario: Checking that it is impossible to add a invoice line to already approved invoice
    * call read('features/check-that-not-possible-add-invoice-line-to-approved-invoice.feature')

  Scenario: Checking that it is impossible to pay for the invoice if no voucher for invoice
    * call read('features/check-that-not-possible-pay-for-invoice-if-no-voucher.feature')

  Scenario: Check that it is not impossible to pay for the invoice without approved status
    * call read('features/check-that-not-possible-pay-for-invoice-without-approved.feature')

  Scenario: Check that voucher exist with parameters
    * call read('features/check-that-voucher-exist-with-parameters.feature')

  Scenario: Checking that voucher lines are created taking into account the expense classes
    * call read('features/create-voucher-lines-honor-expense-classes.feature')

  Scenario: Edit subscription dates after invoice is paid
    * call read('features/edit-subscription-dates-after-invoice-paid.feature')

  Scenario: Update exchange rate after invoice approval
    * call read('features/exchange-rate-update-after-invoice-approval.feature')

  Scenario: Expense classes validation upon invoice approval
    * call read('features/expense-classes-validation.feature')

  Scenario: Check fiscal year balance when using a negative available
    * call read('features/fiscal-year-balance-with-negative-available.feature')

  Scenario: Invoice fiscal years
    * call read('features/invoice-fiscal-years.feature')

  Scenario: Invoice with identical adjustments
    * call read('features/invoice-with-identical-adjustments.feature')

  Scenario: Invoice with lock totals calculated totals
    * call read('features/invoice-with-lock-totals-calculated-totals.feature')

  Scenario: Prorated adjustments special cases
    * call read('features/prorated-adjustments-special-cases.feature')

  Scenario: Set invoice fiscal year automatically
    * call read('features/set-invoice-fiscal-year-automatically.feature')

  Scenario: Vendor address must be populated when retrieve voucher by id
    * call read('features/should_populate_vendor_address_on_get_voucher_by_id.feature')

  Scenario: Voucher numbers
    * call read('features/voucher-numbers.feature')

  Scenario: Voucher with lines using same external account
    * call read('features/voucher-with-lines-using-same-external-account.feature')

  Scenario: Pay Invoice With 0 Value
    * call read('features/pay-invoice-with-0-value.feature')