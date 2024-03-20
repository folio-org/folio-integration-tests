Feature: cross-module integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
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
      | name                                                        |
      | 'finance.module.all'                                        |
      | 'finance.all'                                               |
      | 'orders-storage.module.all'                                 |

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
