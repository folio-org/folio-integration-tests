Feature: bulk-edit integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                     |
      | 'users.all'              |
      | 'perms.all'              |
      | 'bulk-edit.all'          |
      | 'data-export.job.all'    |
      | 'data-export.config.all' |

    * table adminAdditionalPermissions
      | name |

  Scenario: setup users for testing
    Given call read('classpath:global/diku-setup-users.feature')

  Scenario: init test data
    * callonce read('classpath:global/mod_users_init_data.feature')