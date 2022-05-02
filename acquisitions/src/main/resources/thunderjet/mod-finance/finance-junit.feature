Feature: mod-finance integration tests

  Background:
    * url baseUrl
    * table modules
      | name                  |
      | 'mod-orders-storage'  |
      | 'mod-orders'          |
      | 'mod-finance-storage' |
      | 'mod-finance'         |
      | 'mod-login'           |
      | 'mod-permissions'     |
      | 'mod-configuration'   |

    * table adminAdditionalPermissions
      | name                                         |
      | 'acquisitions-units-storage.units.item.post' |
      | 'acquisitions-units-storage.units.item.put'  |
      | 'acquisitions-units-storage.units.item.get'  |
      | 'orders.item.unopen'                         |
      | 'finance.module.all'                         |
      | 'finance.all'                                |



    * table userPermissions
      | name                                         |
      | 'orders.item.unopen'                         |
      | 'finance.all'                                |
      | 'finance.module.all'                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/inventory.feature')