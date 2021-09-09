Feature: mod-patron-blocks integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-patron-blocks'                 |
      | 'mod-inventory'                     |
      | 'mod-inventory-storage'             |
      | 'mod-circulation'                   |
      | 'mod-feesfines'                     |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                        |
      | 'patron-block-limits.item.get'              |
      | 'patron-block-limits.item.post'             |
      | 'patron-block-limits.item.put'              |
      | 'patron-block-limits.item.delete'           |
      | 'usergroups.item.post'                      |
      | 'users.item.post'                           |
      | 'inventory.items.item.post'                 |
      | 'inventory.instances.item.post'             |
      | 'inventory-storage.instance-types.item.post'|
      | 'inventory-storage.holdings.item.post'      |
      | 'inventory-storage.locations.item.post'     |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'     |
      | 'inventory-storage.loan-types.item.post'     |
      | 'patron-block-conditions.item.put'     |
      | 'inventory-storage.material-types.item.post'     |
      | 'circulation.check-out-by-barcode.post'     |
      | 'manualblocks.collection.get'     |
      | 'automated-patron-blocks.collection.get'     |
      | 'circulation-storage.circulation-rules.put'     |
      | 'circulation-storage.loan-policies.item.post'     |
      | 'overdue-fines-policies.item.post'     |
      | 'lost-item-fees-policies.item.post'     |
      | 'circulation-storage.request-policies.item.post'     |
      | 'circulation-storage.patron-notice-policies.item.post'     |
      | 'circulation-storage.loans.item.post'     |
      | 'pubsub.events.post'     |
      | 'circulation.renew-by-barcode.post'     |
      | 'user-summary.item.get'     |
      | 'circulation.requests.item.post'     |
      | 'inventory-storage.service-points.item.post'     |
      | 'circulation.loans.item.put'     |
      | 'circulation-storage.loans.item.get'     |
      | 'owners.item.post'     |
      | 'accounts.item.post'     |
      | 'circulation.loans.declare-item-lost.post'                 |
      | 'accounts.collection.get'                                  |
      | 'feefines.item.post'                                       |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
