Feature: bulk-edit integration tests

  Background:
    * url baseUrl

    * table modules
      | name                    |
      | 'mod-permissions'       |
      | 'mod-login'             |
      | 'mod-users'             |
      | 'mod-inventory'         |
      | 'mod-inventory-storage' |
      | 'mod-source-record-storage' |
      #| 'mod-inventory'         |
      #| 'mod-holdings'          |



    * table userPermissions
      | name                     |
      | 'users.all'              |
      | 'perms.all'              |
      #| 'inventory.items.item.post'              |
      #| 'inventory.items.move.item.post'         |
      #| 'inventory.instances.item.get'           |
       #| 'inventory.instances.item.post'          |
      #| 'inventory.instances.collection.get'     |
      #| 'inventory.holdings.move.item.post'      |
      | 'inventory-storage.holdings.item.post'   |
      | 'inventory-storage.holdings.item.delete' |
      | 'inventory-storage.locations.item.post'  |
      #| 'bulk-edit.all'          |
      #| 'data-export.job.all'    |
      #| 'data-export.config.all' |

    * table adminAdditionalPermissions
      | name |

  Scenario: setup users for testing
    Given call read('classpath:common/setup-users.feature')
    #Given call read('classpath:global/diku-setup-users.feature')

  Scenario: init test data
    * callonce read('classpath:global/mod_item_init_data.feature')