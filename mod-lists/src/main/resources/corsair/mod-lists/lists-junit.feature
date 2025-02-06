Feature: mod-lists integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-lists'               |
      | 'mod-circulation-storage' |
      | 'mod-fqm-manager'         |
    # wait, where's lists? it's installed in the next scenario, keep reading...

    * table userPermissions
      | name                                                        |
      | 'addresstypes.collection.get'                               |
      | 'addresstypes.item.post'                                    |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation.loans.collection.get'                          |
      | 'departments.collection.get'                                |
      | 'fqm.query.all'                                             |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'perms.permissions.collection.get'                          |
      | 'perms.users.assign.immutable'                              |
      | 'perms.users.assign.mutable'                                |
      | 'perms.users.assign.okapi'                                  |
      | 'perms.users.get'                                           |
      | 'perms.users.item.id.delete'                                |
      | 'perms.users.item.post'                                     |
      | 'perms.users.item.put'                                      |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'lists.collection.get'                                      |
      | 'lists.collection.post'                                     |
      | 'lists.configuration.get'                                   |
      | 'lists.item.contents.get'                                   |
      | 'lists.item.delete'                                         |
      | 'lists.item.export.cancel'                                  |
      | 'lists.item.export.download.get'                            |
      | 'lists.item.export.get'                                     |
      | 'lists.item.export.post'                                    |
      | 'lists.item.get'                                            |
      | 'lists.item.post'                                           |
      | 'lists.item.refresh.cancel'                                 |
      | 'lists.item.update'                                         |
      | 'lists.item.versions.collection.get'                        |
      | 'lists.item.versions.item.get'                              |

  Scenario: create tenant and users for testing; install module dependencies
    Given call read('classpath:common/setup-users.feature')

  Scenario: Add sample data for queries
    Given call read('classpath:corsair/mod-lists/features/util/add-list-data.feature')
