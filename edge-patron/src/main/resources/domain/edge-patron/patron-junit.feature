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
      | 'mod-feesfines'           |
      | 'edge-patron'              |
      | 'mod-circulation'        |
      | 'mod-circulation-storage' |

    * table adminAdditionalPermissions
      | name                      |


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
      | 'accounts.collection.get'                                      |
      | 'manualblocks.collection.get'                                  |
      | 'automated-patron-blocks.collection.get'                       |
      | 'lost-item-fees-policies.item.post'                            |
      | 'overdue-fines-policies.item.post'                             |
      | 'patron.account.item.get'                                      |
      | 'patron.hold.item.post'                                        |
      | 'circulation.requests.item.post'                               |
      | 'accounts.item.post'                                           |
      | 'circulation-storage.loan-policies.item.post'                  |
      | 'circulation-storage.patron-notice-policies.item.post'         |
      | 'circulation-storage.request-policies.item.post'               |
      | 'circulation-storage.circulation-rules.put'                    |
      | 'circulation.check-out-by-barcode.post'                       |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
