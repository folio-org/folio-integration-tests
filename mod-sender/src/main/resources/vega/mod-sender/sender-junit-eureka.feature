Feature: mod-sender integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                |
      | 'sender.message-delivery.post'      |
      | 'users.item.post'                   |

    * def requiredApplications = ['app-acquisitions', 'app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
