Feature: edge-rtac integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'edge-rtac'               |

    * table userPermissions
      | name                                                          |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.contributor-name-types.item.post'          |
      | 'inventory.items.item.get'                                    |
      | 'inventory.items.item.post'                                   |
      | 'inventory.instances.item.post'                               |
      | 'inventory.items.item.mark-in-process-non-requestable.post'   |
      | 'inventory.items.item.mark-restricted.post'                   |
      | 'inventory-storage.service-points.item.post'                  |
      | 'inventory-storage.service-points.item.delete'                |
      | 'inventory-storage.service-points.item.put'                   |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.loan-types.item.post'                      |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
