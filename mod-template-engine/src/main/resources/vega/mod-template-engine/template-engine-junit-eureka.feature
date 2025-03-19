Feature: mod-template-engine integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                |
      | 'templates.collection.get'          |
      | 'templates.item.post'               |
      | 'templates.item.get'                |
      | 'templates.item.put'                |
      | 'templates.item.delete'             |
      | 'template-request.post'             |

    * def requiredApplications = ['app-acquisitions', 'app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
