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
      | 'mod-inventory-storage'     |
      | 'mod-source-record-storage' |
      | 'mod-circulation-storage'   |

    * table userPermissions
      | name                                              |
      | 'inn-reach.all'                                   |
      | 'users.item.get'                                  |
      | 'inventory-storage.instances.item.post'           |
      | 'source-storage.records.post'                     |
      | 'source-storage.snapshots.post'                   |
      | 'inn-reach.marc-record-transformation.item.get'   |
      | 'inventory-storage.all'  |
      | 'inventory.all'          |
      | 'configuration.entries.collection.get'|
      | 'configuration.entries.item.post'|
      | 'configuration.entries.item.delete'|
      | 'usergroups.item.post'             |
      | 'perms.permissions.item.post'                                  |
      | 'perms.users.item.put'                                         |
      | 'perms.users.item.post'                                        |
      | 'users.collection.get'                                         |
      | 'users.item.get'                                               |
      | 'users.item.post'                                              |
      | 'circulation-storage.request-preferences.collection.get'       |
      | 'circulation-storage.request-preferences.item.post'            |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')

  Scenario: init inventory data
    * call login testAdmin

    * callonce read(globalPath + 'mod_inventory_init_data.feature')
