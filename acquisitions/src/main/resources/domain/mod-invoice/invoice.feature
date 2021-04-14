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
    * def testTenant = 'test_invoices' + random
    #* def testTenant = 'test_invoices'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name          |
      | 'invoice.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

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

  Scenario: Check vendor address included with batch voucher
    Given call read('features/check-vendor-address-included-with-batch-voucher.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
