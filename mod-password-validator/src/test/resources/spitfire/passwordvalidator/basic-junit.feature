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
      | 'validation.all'                  |
      | 'login.password.validate'         |
      | 'users.collection.get'            |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
