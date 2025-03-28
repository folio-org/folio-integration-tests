Feature: mod-tags integration tests

  Background:
    * url baseUrl
    * table modules
      | name              |
      | 'mod-login'       |
      | 'mod-permissions' |
      | 'mod-tags'        |

    * table userPermissions
      | name                  |
      | 'tags.collection.get' |
      | 'tags.item.delete'    |
      | 'tags.item.get'       |
      | 'tags.item.post'      |
      | 'tags.item.put'       |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
