Feature: mod-audit integration tests

  Background:
    * url baseUrl

    * table modules
      | name              |
      | 'mod-audit'       |
      | 'mod-circulation' |

    * table adminAdditionalPermissions
      | name                                                      |
      | 'circulation-storage.loan-policies.item.post'             |
      | 'circulation-storage.request-policies.item.post'          |
      | 'circulation-storage.patron-notice-policies.item.post'    |
      | 'circulation.rules.put'                                   |
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
      | 'overdue-fines-policies.item.post'                        |
      | 'lost-item-fees-policies.item.post'                       |

    * table userPermissions
      | name                                    |
      | 'audit.marc.bib.collection.get'       |
      | 'audit.marc.authority.collection.get'       |
      | 'audit.config.groups.settings.collection.get'                             |
      | 'audit.config.groups.settings.audit.inventory.collection.get'             |
      | 'audit.config.groups.settings.audit.inventory.records.page.size.item.put' |
      | 'audit.config.groups.settings.item.put'                                   |
      | 'audit.inventory.holdings.collection.get'       |
      | 'circulation-logs.collection.get'       |
      | 'circulation.check-in-by-barcode.post'  |
      | 'circulation.check-out-by-barcode.post' |
      | 'circulation.loans.item.delete'         |
      | 'circulation.renew-by-barcode.post'     |
      | 'circulation.requests.item.post'        |
      | 'circulation.requests.item.put'         |
      | 'circulation.requests.item.delete'      |
      | 'inventory.items.item.put'                               |
      | 'inventory.items.item.get'                               |
      | 'inventory.items.item.post'                               |
      | 'inventory.items.item.delete'                               |
      | 'audit.inventory.instance.collection.get'                               |
      | 'audit.inventory.item.collection.get'                               |
      | 'source-storage.snapshots.post'                               |
      | 'source-storage.records.post'                               |
      | 'source-storage.records.put'                               |
      | 'inventory.instances.item.post'              |
      | 'inventory.instances.item.put'              |
      | 'inventory.instances.item.get'              |
      | 'inventory-storage.holdings.item.get'              |
      | 'inventory-storage.holdings.item.delete'              |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory.holdings.item.put'                    |

  Scenario: create tenant and test user for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: create admin user for testing
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser') { testUser: '#(testAdmin)' }
    Given call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials') { testUser: '#(testAdmin)' }
    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities') { testUser: '#(testAdmin)', userPermissions: '#(adminAdditionalPermissions)' }

  Scenario: setup initial data
    Given call read('classpath:eureka-global/initTest.feature')