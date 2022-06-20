Feature: mod-patron-blocks integration tests

  Background:
    * url baseUrl
    * table modules
      | name                    |
      | 'mod-login'             |
      | 'mod-permissions'       |
      | 'mod-patron-blocks'     |
      | 'mod-inventory'         |
      | 'mod-inventory-storage' |
      | 'mod-circulation'       |
      | 'mod-feesfines'         |

    * table userPermissions
      | name                                                      |
      | 'accounts.collection.get'                                 |
      | 'accounts.item.post'                                      |
      | 'automated-patron-blocks.collection.get'                  |
      | 'circulation-storage.circulation-rules.put'               |
      | 'circulation-storage.loan-policies.item.post'             |
      | 'circulation-storage.loans.item.get'                      |
      | 'circulation-storage.loans.item.post'                     |
      | 'circulation-storage.patron-notice-policies.item.post'    |
      | 'circulation-storage.request-policies.item.post'          |
      | 'circulation.check-out-by-barcode.post'                   |
      | 'circulation.loans.declare-item-lost.post'                |
      | 'circulation.loans.item.put'                              |
      | 'circulation.renew-by-barcode.post'                       |
      | 'circulation.requests.item.post'                          |
      | 'feefines.item.post'                                      |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.loan-types.item.post'                  |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.material-types.item.post'              |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory.instances.item.post'                           |
      | 'inventory.items.item.post'                               |
      | 'lost-item-fees-policies.item.post'                       |
      | 'manualblocks.collection.get'                             |
      | 'overdue-fines-policies.item.post'                        |
      | 'owners.item.post'                                        |
      | 'patron-block-conditions.item.put'                        |
      | 'patron-block-limits.item.delete'                         |
      | 'patron-block-limits.item.get'                            |
      | 'patron-block-limits.item.post'                           |
      | 'patron-block-limits.item.put'                            |
      | 'pubsub.events.post'                                      |
      | 'user-summary.item.get'                                   |
      | 'usergroups.collection.get'                               |
      | 'usergroups.item.post'                                    |
      | 'users.collection.get'                                    |
      | 'users.item.post'                                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
