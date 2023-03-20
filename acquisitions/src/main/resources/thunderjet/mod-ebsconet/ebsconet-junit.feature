@parallel=false
Feature: mod-ebsconet integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-configuration' |
      | 'mod-ebsconet'      |
      | 'mod-login'         |
      | 'mod-orders'        |
      | 'mod-organizations' |
      | 'mod-permissions'   |
      | 'mod-invoice'       |

    * table userPermissions
      | name                |
      | 'ebsconet.all'      |
      | 'orders.all'        |
      | 'finance-storage.ledger-rollovers-errors.collection.get'|
      | 'finance-storage.ledger-rollovers-errors.item.put'      |
      | 'finance-storage.ledger-rollovers-errors.item.delete'   |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
