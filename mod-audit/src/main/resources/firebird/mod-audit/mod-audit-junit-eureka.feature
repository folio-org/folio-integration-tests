Feature: mod-audit integration tests

  Background:
    * url baseUrl

    * table modules
      | name                                     |
      | 'mod-audit'                              |
      | 'mod-circulation'                        |

    * table userPermissions
      | name                                                      |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.instances.item.post'                   |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.holdings-sources.item.post'            |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.loan-types.item.post'                  |
      | 'inventory-storage.material-types.item.post'              |
      | 'usergroups.item.post'                                    |
      | 'users.item.post'                                         |
      | 'inventory.items.item.post'                               |
      | 'circulation-storage.loan-policies.item.post'             |
      | 'circulation-storage.request-policies.item.post'          |
      | 'circulation-storage.patron-notice-policies.item.post'    |
      | 'overdue-fines-policies.item.post'                        |
      | 'lost-item-fees-policies.item.post'                       |
      | 'circulation.rules.put'                                   |
      | 'circulation-logs.collection.get'                         |
      | 'circulation.check-in-by-barcode.post'                    |
      | 'circulation.check-out-by-barcode.post'                   |
      | 'circulation.loans.item.delete'                           |
      | 'circulation.renew-by-barcode.post'                       |
      | 'circulation.requests.item.post'                          |
      | 'circulation.requests.item.put'                           |
      | 'circulation.requests.item.delete'                        |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
    Given call read('classpath:eureka-global/initTest.feature')