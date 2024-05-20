Feature: mod-linked-data integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                      |
      | 'mod-login'                               |
      | 'mod-permissions'                         |
      | 'mod-users'                               |
      | 'mod-linked-data'                         |

    * table userPermissions
      | name                                          |
      | 'linked.data.bibframe.post'                   |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
