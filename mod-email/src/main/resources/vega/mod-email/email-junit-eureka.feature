Feature: mod-email integration tests

  Background:
    * url baseUrl


    * table userPermissions
      | name                                |
      | 'email.message.post'                |
      | 'email.message.collection.get'      |
      | 'email.message.delete'              |

    * def requiredApplications = ['app-acquisitions','app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
