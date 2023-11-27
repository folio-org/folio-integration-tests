Feature: mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-inventory-storage'             |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |

    * table userPermissions
      | name                                                      |
      | 'addresstypes.item.post'                                  |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.loan-types.item.post'                  |
      | 'inventory-storage.material-types.item.post'              |
      | 'inventory-storage.items.item.post'                       |
      | 'inventory-storage.instances.item.post'                   |
      | 'circulation-storage.loans.item.post'                     |
      | 'users.item.post'                                         |
      | 'users.item.delete'                                       |
      | 'fqm.query.all'                                           |
      | 'fqm.query.purge'                                         |
      | 'fqm.materializedViews.post'                              |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-fqm-manager/features/util/add-query-data.feature')
