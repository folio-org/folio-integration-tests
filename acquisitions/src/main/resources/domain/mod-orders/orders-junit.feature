Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-configuration' |
      | 'mod-login'         |
      | 'mod-orders'        |
      | 'mod-permissions'   |
      | 'mod-tags'          |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name         |
      | 'orders.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
