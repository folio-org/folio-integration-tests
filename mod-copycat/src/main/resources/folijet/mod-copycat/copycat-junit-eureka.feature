Feature: mod-copycat integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                                      |
      | 'copycat.profiles.collection.get'                         |
      | 'copycat.profiles.item.post'                              |
      | 'copycat.profiles.item.get'                               |
      | 'copycat.profiles.item.put'                               |
      | 'copycat.profiles.item.delete'                            |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')