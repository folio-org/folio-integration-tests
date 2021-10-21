Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                                     |
      | 'mod-login'                                              |
      | 'mod-permissions'                                        |
      | 'mod-circulation'                                        |
      | 'mod-inventory'                                          |
      | 'mod-inventory-storage'                                  |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                                      |
      | 'automated-patron-blocks.collection.get'                  |
      | 'circulation.check-out-by-barcode.post'                   |
      | 'circulation.loans.collection.get'                        |
      | 'circulation-storage.patron-notice-policies.item.post'    |
      | 'circulation-storage.request-policies.item.post'          |
      | 'circulation-storage.loan-policies.item.post'             |
      | 'circulation-storage.circulation-rules.put'               |
      | 'inventory.items.item.post'                               |
      | 'inventory.instances.item.post'                           |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.contributor-name-types.item.post'      |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.loan-types.item.post'                  |
      | 'inventory-storage.material-types.item.post'              |
      | 'lost-item-fees-policies.item.post'                       |
      | 'manualblocks.collection.get'                             |
      | 'overdue-fines-policies.item.post'                        |
      | 'usergroups.item.post'                                    |
      | 'users.item.post'                                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
