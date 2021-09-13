Feature: mod-invoice integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-invoice'       |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name          |
      | 'invoice.all'                                               |
      | 'voucher-storage.module.all'                                |
      | 'finance.all'                                               |
      | 'finance.module.all'                                        |
      | 'orders-storage.order-invoice-relationships.collection.get' |
      | 'organizations-storage.organizations.item.post'             |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
