Feature: mod-invoice integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-invoice'       |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |

    * def random = callonce randomMillis
    * def testTenant = 'testinvoices' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |
      | 'finance.all'                                               |
      | 'voucher-storage.module.all'                                |
      | 'orders-storage.order-invoice-relationships.collection.get' |
      | 'organizations-storage.organizations.item.post'             |

    * table userPermissions
      | name          |
      | 'invoice.all'                                               |
      | 'finance.all'                                               |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Batch voucher export with many lines
    Given call read('features/batch-voucher-export-with-many-lines.feature')

  Scenario: Prorated adjustments special cases
    Given call read('features/prorated-adjustments-special-cases.feature')

  Scenario: Check remaining amount upon invoice approval
    Given call read('features/check-remaining-amount-upon-invoice-approval.feature')

  Scenario: Check invoice and invoice lines deletion restrictions
    Given call read('features/check-invoice-and-invoice-lines-deletion-restrictions.feature')

  Scenario: Check invoice lines and documents are deleted with invoice
    Given call read('features/check-invoice-lines-and-documents-are-deleted-with-invoice.feature')

  Scenario: Checking that voucher lines are created taking into account the expense classes
    Given call read('features/create-voucher-lines-honor-expense-classes.feature')

  Scenario: Update exchange rate after invoice approval
    Given call read('features/exchange-rate-update-after-invoice-approval.feature')

  Scenario: Expense classes validation upon invoice approval
    Given call read('features/expense-classes-validation.feature')

  Scenario: Invoice with lock totals calculated totals
    Given call read('features/invoice-with-lock-totals-calculated-totals.feature')

  Scenario: Check invoice approve flow if lockTotal is specified
    Given call read('features/check-lock-totals-and-calculated-totals-in-invoice-approve-time.feature')

  Scenario: Voucher with lines using same external account
    Given call read('features/voucher-with-lines-using-same-external-account.feature')

  Scenario: Vendor address must be populated when retrieve voucher by id
    Given call read('features/should_populate_vendor_address_on_get_voucher_by_id.feature')

  Scenario: Check approve and pay invoice with odd number of pennies in total
    Given call read('features/check-approve-and-pay-invoice-with-odd-pennies-number.feature')
#
#  Scenario: Check vendor address included with batch voucher
#    Given call read('features/check-vendor-address-included-with-batch-voucher.feature')

  Scenario: Check that can not approve invoice if organization is not vendor
    Given call read('features/check-that-can-not-approve-invoice-if-organization-is-not-vendor.feature')

  Scenario: Voucher numbers
    Given call read('features/voucher-numbers.feature')

  Scenario: Check approve and pay invoice with 0$ amount
    Given call read('features/check-approve-and-pay-invoice-with-zero-dollar-amount.feature')

  Scenario: Check that voucher exist with parameters
    Given call read('features/check-that-voucher-exist-with-parameters.feature')

  Scenario: Check that it is not impossible to pay for the invoice without approved status
    Given call read('features/check-that-not-possible-pay-for-invoice-without-approved.feature')

  Scenario: Cancel invoice
    Given call read('features/cancel-invoice.feature')

  Scenario: Check that error response should have fundcode included when when there is not enough budget
    Given call read('features/check-error-respose-with-fundcode-upon-invoice-approval.feature')

  Scenario: Edit subscription dates after invoice is paid
    Given call read('features/edit-subscription-dates-after-invoice-paid.feature')

  Scenario: Check fiscal year balance when using a negative available
    Given call read('features/fiscal-year-balance-with-negative-available.feature')

  Scenario: Invoice fiscal years
    Given call read('features/invoice-fiscal-years.feature')

  Scenario: Approve and pay invoice with past fiscal year
    Given call read('features/approve-and-pay-invoice-with-past-fiscal-year.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
