Feature: mod-password-validator integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                              |
      | 'validation.rules.item.post'      |
      | 'validation.rules.collection.get' |
      | 'validation.rules.item.get'       |
      | 'validation.rules.item.put'       |
      | 'validation.validate.post'        |

    * def requiredApplications = ['app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: create dummy admin user for validate.feature
    Given call read('classpath:spitfire/passwordvalidator/eureka-features/setup/setup-dummy-admin.feature')