Feature: edge-inn-reach integration tests

  Background:
    * url baseUrl
    * table modules
      | name  |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-inn-reach'             |

    * table userPermissions
      | name  |
      | 'inn-reach.all'                                   |
