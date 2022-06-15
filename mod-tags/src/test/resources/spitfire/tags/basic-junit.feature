Feature: mod-tags integration tests

  Background:
    * url baseUrl
    * table modules
      | name              |
      | 'mod-login'       |
      | 'mod-permissions' |
      | 'mod-tags'        |

    * table userPermissions
      | name       |
      | 'tags.all' |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
