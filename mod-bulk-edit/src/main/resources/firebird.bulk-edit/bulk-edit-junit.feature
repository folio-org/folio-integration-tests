Feature: bulk-edit integration tests mod-users

  Background:
    * url baseUrl
    * table modules
      | name                     |
      | 'mod-data-export-spring' |
      | 'mod-data-export-worker' |
      | 'mod-inventory-storage'  |
      | 'mod-permissions'        |
      | 'mod-login'              |

    * table userPermissions
      | name            |
      | 'users.all'     |
      | 'perms.all'     |
      | 'bulk-edit.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init test data
#    * call login testAdmin
    * callonce read('classpath:global/mod_users_init_data.feature')