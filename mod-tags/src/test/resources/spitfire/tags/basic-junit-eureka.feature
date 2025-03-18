Feature: mod-tags integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                  |
      | 'tags.collection.get' |
      | 'tags.item.delete'    |
      | 'tags.item.get'       |
      | 'tags.item.post'      |
      | 'tags.item.put'       |

    * def requiredApplications = ['app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
