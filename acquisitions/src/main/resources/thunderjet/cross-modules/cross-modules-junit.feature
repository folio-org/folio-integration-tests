Feature: cross-module integration tests

  Background:
    * url baseUrl
    # Order of the modules below is important: mod-pubsub should come before mod-circulation
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations-storage' |

    * table adminAdditionalPermissions
      | name                        |
      | 'finance.module.all'        |
      | 'finance.all'               |
      | 'orders-storage.module.all' |

    * table userPermissions
      | name                          |
      | 'invoice.all'                 |
      | 'orders.all'                  |
      | 'finance.all'                 |
      | 'orders.item.approve'         |
      | 'orders.item.reopen'          |
      | 'orders.item.unopen'          |
      | 'invoices.fiscal-year.update' |
      | 'invoice.item.approve'        |
      | 'invoice.item.pay'            |
      | 'invoice.item.cancel'         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
