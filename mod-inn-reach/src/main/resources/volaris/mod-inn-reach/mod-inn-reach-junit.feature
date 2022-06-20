Feature: mod-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-inn-reach'             |

    * table userPermissions
      | name                                   |
      | 'inn-reach.all'                        |
      | 'users.item.get'                       |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')
