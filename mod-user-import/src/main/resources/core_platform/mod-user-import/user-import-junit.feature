Feature: mod-user-import integration tests

  Background:
    * callonce login admin
    * url baseUrl
    # These modules are registered with the generated test tenant in tenant.feature.
    * table modules
      | name                                |
      # Registering okapi is absolutely critical because this enables inter-module communication which
      # mod-user-import needs. It communicates with mod-users for example. But adding mod-users
      # below won't be enough for okapi to be able to find it when the two modules need to talk.
      | 'okapi'                             |
      # These are needed for an authenticated user to be created.
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      # For retrieving the results of the import to check that all is well.
      | 'mod-users'                         |
      | 'mod-user-import'                   |

    * table userPermissions
      | name                                |
      | 'user-import.all'                   |
      | 'users.all'                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

