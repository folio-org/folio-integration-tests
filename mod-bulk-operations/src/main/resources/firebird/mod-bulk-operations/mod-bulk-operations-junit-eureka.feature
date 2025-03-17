Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * table userPermissions
      | name                                                    |
      | 'addresstypes.item.post'                                  |
      | 'bulk-edit.item.post'                                     |
      | 'bulk-edit.start.item.post'                               |
      | 'bulk-operations.all'                                     |
      | 'bulk-operations.download.item.get'                      |
      | 'bulk-operations.item.content-update.post'               |
      | 'bulk-operations.item.errors.get'                        |
      | 'bulk-operations.item.inventory.get'                     |
      | 'bulk-operations.item.inventory.put'                     |
      | 'bulk-operations.item.marc-content-update.post'          |
      | 'bulk-operations.item.preview.get'                       |
      | 'bulk-operations.item.start.post'                        |
      | 'bulk-operations.item.upload.post'                       |
      | 'bulk-operations.item.users.get'                         |
      | 'bulk-operations.item.users.put'                         |
      | 'bulk-operations.list-users.collection.get'              |
      | 'configuration.entries.collection.get'                   |
      | 'data-export.job.item.get'                               |
      | 'data-export.job.item.post'                              |
      | 'departments.item.post'                                  |
      | 'inventory-storage.all'                                  |
      | 'inventory-storage.classification-types.item.post'       |
      | 'inventory-storage.contributor-name-types.item.post'     |
      | 'inventory-storage.contributor-types.collection.get'     |
      | 'inventory-storage.holdings-sources.item.get'            |
      | 'inventory-storage.holdings-sources.item.post'           |
      | 'inventory-storage.holdings.collection.get'              |
      | 'inventory-storage.holdings.item.get'                    |
      | 'inventory-storage.holdings.item.post'                   |
      | 'inventory-storage.holdings.item.put'                    |
      | 'inventory-storage.identifier-types.item.post'           |
      | 'inventory-storage.instance-formats.collection.get'      |
      | 'inventory-storage.instance-types.collection.get'        |
      | 'inventory-storage.instance-types.item.post'             |
      | 'inventory-storage.instances.item.post'                  |
      | 'inventory-storage.location-units.campuses.item.post'    |
      | 'inventory-storage.location-units.institutions.item.post'|
      | 'inventory-storage.location-units.libraries.item.post'   |
      | 'inventory-storage.locations.item.get'                   |
      | 'inventory-storage.locations.item.post'                  |
      | 'inventory-storage.loan-types.item.get'                  |
      | 'inventory-storage.service-points.item.post'             |
      | 'inventory-storage.statistical-code-types.item.post'     |
      | 'inventory-storage.statistical-codes.item.post'          |
      | 'inventory.instances.collection.get'                     |
      | 'inventory.instances.item.get'                           |
      | 'inventory.instances.item.post'                          |
      | 'inventory.instances.item.put'                           |
      | 'inventory.items.collection.get'                         |
      | 'inventory.items.item.get'                               |
      | 'inventory.items.item.post'                              |
      | 'inventory.items.item.put'                               |
      | 'proxiesfor.item.post'                                   |
      | 'source-storage.records.post'                            |
      | 'source-storage.snapshots.post'                          |
      | 'usergroups.collection.get'                              |
      | 'usergroups.item.get'                                    |
      | 'usergroups.item.post'                                   |
      | 'users.collection.get'                                   |
      | 'users.item.get'                                         |
      | 'users.item.post'                                        |
      | 'users.item.put'                                         |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']


  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')


