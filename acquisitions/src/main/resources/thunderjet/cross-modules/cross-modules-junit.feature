Feature: cross-module integration tests

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

    * table adminAdditionalPermissions
      | name                                                        |
      | 'finance.module.all'                                        |
      | 'finance.all'                                               |
      | 'orders-storage.module.all'                                 |

    * table userPermissions
      | name                       |
      | 'invoice.all'              |
      | 'orders.all'               |
      | 'finance.all'              |
      | 'orders.item.approve'      |
      | 'orders.item.reopen'       |
      | 'orders.item.unopen'       |

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
