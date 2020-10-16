Feature: mod-finance integration tests

  Background:
    * url baseUrl
    * table modules
      | name                  |
      | 'mod-finance'         |
      | 'mod-login'           |
      | 'mod-permissions'     |
      | 'mod-finance-storage' |
      | 'mod-configuration'   |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name          |
      | 'finance.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
