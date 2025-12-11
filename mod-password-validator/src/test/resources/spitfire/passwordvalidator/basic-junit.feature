Feature: mod-password-validator integration tests

  Background:
    * url baseUrl
    * table modules
      | name         |
      | 'mod-login'                       |
      | 'mod-permissions'                 |
      | 'mod-users'                       |
      | 'mod-password-validator'          |

    * table userPermissions
      | name                              |
      | 'validation.rules.item.post'      |
      | 'validation.rules.item.get'       |
      | 'validation.rules.item.put'       |
      | 'validation.validate.post'        |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: create dummy admin user for validate.feature
    Given call read('classpath:spitfire/passwordvalidator/features/setup/setup-dummy-admin.feature')