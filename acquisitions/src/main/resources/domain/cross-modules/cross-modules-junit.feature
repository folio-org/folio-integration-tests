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

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                  |
      | 'invoice.all'         |
      | 'orders.all'          |
      | 'orders.item.approve' |
      | 'orders.item.reopen'  |
      | 'orders.item.unopen'  |
      | 'finance.all'         |

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
