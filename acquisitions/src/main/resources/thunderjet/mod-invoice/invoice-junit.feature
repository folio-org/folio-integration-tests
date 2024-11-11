Feature: mod-invoice integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-permissions'           |
      | 'mod-audit'                 |
      | 'mod-configuration'         |
      | 'mod-invoice'               |
      | 'mod-invoice-storage'       |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |
      | 'mod-orders'                |
      | 'mod-orders-storage'        |

    * table adminAdditionalPermissions
      | name                                                        |
      | 'finance.all'                                               |
      | 'voucher-storage.module.all'                                |
      | 'orders-storage.order-invoice-relationships.collection.get' |
      | 'organizations-storage.organizations.item.post'             |

    * table userPermissions
      | name                                  |
      | 'orders.all'                          |
      | 'invoice.all'                         |
      | 'finance.all'                         |
      | 'invoices.fiscal-year.update.execute' |
      | 'invoice.item.approve.execute'        |
      | 'invoice.item.pay.execute'            |
      | 'invoice.item.cancel.execute'         |
      | 'acquisition.invoice.events.get'      |
      | 'acquisition.invoice-line.events.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
