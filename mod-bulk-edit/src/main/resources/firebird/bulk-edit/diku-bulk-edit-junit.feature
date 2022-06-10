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
      | 'inventory-storage.all'  |
      | 'inventory.all'          |
      | 'configuration.entries.collection.get'|
      | 'configuration.entries.item.post'|
      | 'configuration.entries.item.delete'|

    * table adminAdditionalPermissions
      | name |

  Scenario: setup users for testing
    Given call read('classpath:global/diku-setup-users.feature')

  Scenario: init test data
    * callonce read('classpath:global/mod_users_init_data.feature')

  Scenario: init test data
   * callonce read('classpath:global/mod_item_init_data.feature')