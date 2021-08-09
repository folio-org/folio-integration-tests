Feature: mod-orders integration tests

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
    * def testTenant = 'test_cross_modules' + random
    #* def testTenant = 'test_cross_modules1'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                                        |
      | 'invoice.all'                                               |
      | 'orders.all'                                                |
      | 'orders.item.approve'                                       |
      | 'orders.item.reopen'                                        |
      | 'orders.item.unopen'                                        |
      | 'finance.all'                                               |
      | 'orders-storage.order-invoice-relationships.collection.get' |
      | 'orders-storage.order-invoice-relationships.item.delete' |


    * table desiredPermissions
      | name                  |
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

  Scenario: link invoice line to po line
    Given call read('features/link-invoice-line-to-po-line.feature')

  Scenario: order invoice relation
    Given call read('features/order-invoice-relation.feature')

  Scenario: unopen order and add addition pol and check encumbrances
    Given call read('features/unopen-order-and-add-addition-pol-and-check-encumbrances.feature')

  Scenario: unopen order simple case
    Given call read('features/unopen-order-simple-case.feature')

  Scenario: create-order-and-approve-invoice-were-pol-without-fund-distributions
    Given call read('features/create-order-and-approve-invoice-were-pol-without-fund-distributions.feature')

  Scenario: order-invoice-relation-can-be-changed
    Given call read('features/order-invoice-relation-can-be-changed.feature')

  Scenario: order-invoice-relation-can-be-deleted
    Given call read('features/order-invoice-relation-can-be-deleted.feature')

  Scenario: order-invoice-relation-must-be-deleted-if-invoice-deleted
    Given call read('features/order-invoice-relation-must-be-deleted-if-invoice-deleted.feature')


  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
