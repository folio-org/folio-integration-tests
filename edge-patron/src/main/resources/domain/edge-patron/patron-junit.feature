Feature: edge-patron integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'okapi'                   |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'mod-feesfines'            |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                                           |
      | 'inventory.instances.item.post'                                |
      | 'inventory.items.item.post'                                    |
      | 'inventory-storage.holdings.item.post'                         |
      | 'inventory-storage.locations.item.post'                        |
      | 'inventory-storage.instance-types.item.post'                   |
      | 'inventory-storage.location-units.institutions.item.post'      |
      | 'inventory-storage.location-units.campuses.item.post'          |
      | 'inventory-storage.location-units.libraries.item.post'         |
      | 'inventory-storage.service-points.item.post'                   |
      | 'inventory-storage.loan-types.item.post'                       |
      | 'inventory-storage.material-types.item.post'                   |
      | 'usergroups.item.post'                                         |
      | 'users.item.post'                                              |
      | 'owners.item.post'                                             |
      | 'accounts.item.post'                                           |
      | 'accounts.collection.get'                                      |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
