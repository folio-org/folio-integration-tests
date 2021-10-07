Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                 |
      | 'mod-configuration'  |
      | 'mod-permissions'    |
      | 'mod-login'          |
      | 'mod-orders-storage' |
      | 'mod-orders'         |
    #  | 'mod-tags'           |
      | 'mod-invoice'        |

    * def random = callonce randomMillis
    * def testTenant = 'test_orders' + random
    #* def testTenant = 'test_orders4'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                   |
      | 'orders-storage.module.all'            |
      | 'finance.module.all'                   |


    * table userPermissions
      | name                                   |
      | 'orders.all'                           |
      | 'finance.all'                          |
      | 'inventory.all'                        |
      | 'tags.all'                             |
      | 'orders.item.approve' |
      | 'orders.item.reopen'  |
      | 'orders.item.unopen'  |

    * table desiredPermissions
      | desiredPermissionName |
      | 'orders.item.approve' |
      | 'orders.item.reopen'  |
      | 'orders.item.unopen'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

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

  Scenario: Close order and release encumbrances
    Given call read('features/close-order-and-release-encumbrances.feature')

  Scenario: Check new tags created in central tag repository
    Given call read('features/check-new-tags-in-central-tag-repository.feature')

  Scenario: Should fail Open ongoing order if interval or renewal date is not set
    Given call read('features/open-ongoing-order-should-fail-if-interval-or-renewaldate-notset.feature')

  Scenario: Check opening an order links to the right instance
    Given call read('features/open-order-instance-link.feature')

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

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
