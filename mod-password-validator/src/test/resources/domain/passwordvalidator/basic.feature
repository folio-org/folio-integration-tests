Feature: mod-password-validator integration tests

  Background:
    * url baseUrl
    * table modules
      | name         |
      | 'mod-login'                       |
      | 'mod-permissions'                 |
      | 'mod-users'                       |
      | 'mod-password-validator'          |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name         |
      | 'okapi.proxy.tenants.post'        |
      | 'validation.all'                  |
      | 'login.password.validate'         |
      | 'users.collection.get'            |

  Scenario: Create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
    Given call login testAdmin

  Scenario: Run tests for validation rule feature
    Given call read('features/rules.feature')

  Scenario: Destroy data
    Given call read('classpath:common/destroy-data.feature')
