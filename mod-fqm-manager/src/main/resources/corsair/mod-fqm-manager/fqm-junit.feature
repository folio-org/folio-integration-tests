Feature: mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-inventory'                     |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |

    * table userPermissions
      | name                                          |
      | 'addresstypes.item.post'                      |
      | 'addresstypes.item.delete'                    |
      | 'inventory.items.collection.get'              |
      | 'inventory.items.item.post'                   |
      | 'inventory.items.item.delete'                 |
      | 'users.item.post'                             |
      | 'users.item.delete'                           |
      | 'fqm.query.all'                               |
      | 'fqm.query.purge'                             |
      | 'fqm.materializedViews.post'                  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
