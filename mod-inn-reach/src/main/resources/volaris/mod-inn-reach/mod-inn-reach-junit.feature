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

    * table userPermissions
      | name                                              |
      | 'inn-reach.all'                                   |
      | 'users.item.get'                                  |
      | 'inventory-storage.instances.item.post'           |
      | 'source-storage.records.post'                     |
      | 'source-storage.snapshots.post'                   |
      | 'inn-reach.marc-record-transformation.item.get'   |

  Scenario: create tenant and users for testing for mod-inn-reach
    Given call read('classpath:common/setup-users.feature')

  Scenario: init inventory data
    * call login testAdmin

    * callonce read(globalPath + 'mod_inventory_init_data.feature')
