Feature: mod-lists integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-users'                         |
      | 'mod-circulation-storage'           |
      | 'mod-fqm-manager'                   |
      | 'mod-lists'                         |

    * table userPermissions
      | name                                                        |
      | 'addresstypes.item.post'                                    |
      | 'addresstypes.collection.get'                               |
      | 'usergroups.collection.get'                                 |
      | 'departments.collection.get'                                |
      | 'users.item.get'                                            |
      | 'users.collection.get'                                      |
      | 'users.item.post'                                           |
      | 'users.item.delete'                                         |
      | 'circulation.loans.collection.get'                          |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'fqm.query.all'                                             |
      | 'lists.collection.get'                                      |
      | 'lists.collection.post'                                     |
      | 'lists.item.get'                                            |
      | 'lists.item.contents.get'                                   |
      | 'lists.item.post'                                           |
      | 'lists.item.refresh.cancel'                                 |
      | 'lists.item.export.post'                                    |
      | 'lists.item.export.get'                                     |
      | 'lists.item.export.download.get'                            |
      | 'lists.item.export.cancel'                                  |
      | 'lists.item.delete'                                         |
      | 'lists.item.update'                                         |
      | 'lists.configuration.get'                                   |
      | 'lists.item.versions.collection.get'                        |
      | 'lists.item.versions.item.get'                              |
      | 'user-tenants.collection.get'                               |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'fqm.query.privileged.async.results.post'                   |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-lists/features/util/add-list-data.feature')
