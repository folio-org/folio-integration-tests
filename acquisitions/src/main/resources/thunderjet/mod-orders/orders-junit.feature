Feature: mod-orders integration tests

  Background:
    * url baseUrl
    # Order of the modules below is important: mod-pubsub should come before mod-circulation
    # Including all only required modules is needed for dev env, where checkDepsDuringModInstall is false
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-tags'                  |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-template-engine'       |
      | 'mod-feesfines'             |


    * table adminAdditionalPermissions
      | name                                         |
      | 'orders-storage.module.all'                  |
      | 'finance.module.all'                         |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post'   |
      | 'acquisitions-units.units.item.post'         |


    * table userPermissions
      | name                                      |
      | 'orders.all'                              |
      | 'finance.all'                             |
      | 'inventory.all'                           |
      | 'tags.all'                                |
      | 'orders.item.approve'                     |
      | 'orders.item.reopen'                      |
      | 'orders.item.unopen'                      |
      | 'invoice.all'                             |
      | 'audit.all'                               |
      | 'orders-storage.claiming.process.execute' |
      | 'inventory-storage.instances.item.get'    |
      | 'inventory-storage.items.item.get'        |
      | 'orders-storage.titles.item.get'          |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/orders.feature')
