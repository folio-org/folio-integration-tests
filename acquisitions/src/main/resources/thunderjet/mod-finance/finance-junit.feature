Feature: mod-finance integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |
      | 'mod-invoice'               |
      | 'mod-invoice-storage'       |
      | 'mod-login'                 |
      | 'mod-orders'                |
      | 'mod-orders-storage'        |
      | 'mod-organizations-storage' |
      | 'mod-permissions'           |
      | 'mod-users'                 |

    * table adminAdditionalPermissions
      | name                                         |
      | 'acquisitions-units-storage.units.item.post' |
      | 'acquisitions-units-storage.units.item.put'  |
      | 'acquisitions-units-storage.units.item.get'  |
      | 'finance.module.all'                         |
      | 'finance.all'                                |



    * table userPermissions
      | name                                         |
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