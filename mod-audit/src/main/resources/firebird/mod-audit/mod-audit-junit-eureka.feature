Feature: mod-audit integration tests

  Background:
    * url baseUrl

    * table modules
      | name              |
      | 'mod-audit'       |
      | 'mod-circulation' |

    * table adminAdditionalPermissions
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
      | 'overdue-fines-policies.item.post'                        |
      | 'lost-item-fees-policies.item.post'                       |

    * table userPermissions
      | name                                                   |
      | 'circulation-storage.loan-policies.item.post'          |
      | 'circulation-storage.request-policies.item.post'       |
      | 'circulation-storage.patron-notice-policies.item.post' |
      | 'circulation.rules.put'                                |
      | 'circulation-logs.collection.get'                      |
      | 'circulation.check-in-by-barcode.post'                 |
      | 'circulation.check-out-by-barcode.post'                |
      | 'circulation.loans.item.delete'                        |
      | 'circulation.renew-by-barcode.post'                    |
      | 'circulation.requests.item.post'                       |
      | 'circulation.requests.item.put'                        |
      | 'circulation.requests.item.delete'                     |

  Scenario: create tenant and test user for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: create admin user for testing
    * def tempTestUser = testUser
    * def tempUserPermissions = userPermissions
    * def testUser = { tenant: "#(testTenant)", name: '#(testAdmin.name)', password: '#(testAdmin.password)' }
    * def userPermissions = adminAdditionalPermissions
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')
    Given call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
    * def testUser = tempTestUser
    * def userPermissions = tempUserPermissions

  Scenario: setup initial data
    Given call read('classpath:eureka-global/initTest.feature')