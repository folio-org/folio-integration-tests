@parallel=false
Feature: Initialize mod-consortia integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * configure readTimeout = 600000
    * configure connectTimeout = 600000

    # Permissions for consortiaAdmin and universityUser
    * table userPermissions
      | name                                                        |
      | 'circulation.rules.put'                                     |
      | 'circulation.requests.item.get'                             |
      | 'circulation.requests.item.post'                            |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.collection.get' |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.collection.get'       |
      | 'circulation-storage.request-policies.item.post'            |
      | 'configuration.entries.collection.get'                      |
      | 'configuration.entries.item.delete'                         |
      | 'configuration.entries.item.get'                            |
      | 'configuration.entries.item.post'                           |
      | 'configuration.entries.item.put'                            |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.instance-statuses.item.post'             |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory.holdings.move.item.post'                         |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.delete'                           |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.item.post'                                 |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.move.item.post'                            |
      | 'inventory.tenant-items.collection.get'                     |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'perms.users.get'                                           |
      | 'perms.users.item.put'                                      |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.item.post'                                      |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'users.item.put'                                            |
      | 'patron.account.item-allowed-service-points.item.get'       |
      | 'patron.account.instance-allowed-service-points.item.get'   |
      | 'tlr.settings.get'                                          |
      | 'tlr.settings.put'                                          |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.post'                          |
      | 'consortia.user-tenants.item.delete'                        |
      | 'consortia.user-tenants.item.get'                           |
      | 'consortium-search.items.item.get'                          |
      | 'patron.account.item-hold.item.post'                        |
      | 'patron.account.instance-hold.item.post'                    |

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity
    # create disable instance matching config id for university tenant
    * def isInstanceMatchingDisabledId = callonce uuid

    # generate names for tenants
    * def random = callonce randomMillis
    * def uuids = callonce uuids 4
    * def centralTenantUuid = uuids[0]
    * def centralTenantName = 'central' + random
    * def centralTenantId = centralTenantName
    * def centralTenant = { id : '#(centralTenantUuid)', name: '#(centralTenantName)' }
    * def universityTenantUuid = uuids[1]
    * def universityTenantName = 'university' + random
    * def universityTenantId = universityTenantName
    * def universityTenant = { id : '#(universityTenantUuid)', name: '#(universityTenantName)' }

    * def universityUserId = uuids[2]

    # define consortium
    * def consortiumId = uuids[3]

    # define main users
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenantName)' }
    * def universityUser = { id: '#(universityUserId)', username: 'university_user', password: 'university_user_password', type: 'staff', tenant: '#(universityTenantName)' }

    * def centralUser = { id: '#(centralUserId)', username: 'central_user', password: 'central_user_password', type: 'staff', tenant: '#(centralTenantName)' }

    # reusable features
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def postUser = read('classpath:common-consortia/eureka/initData.feature@PostUser')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def getAuthorizationToken = read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def configureAccessTokenTime = read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime')

  Scenario: Create Central and University tenants and Set up Admins
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login-keycloak'        |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-feesfines'             |
      | 'mod-consortia-keycloak'    |
      | 'edge-patron'               |
      | 'mod-patron'                |
      | 'mod-tlr'                   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-consortia'             |
      | 'mod-search'                |

    * call setupTenant { tenantId: '#(centralTenantUuid)', tenant: '#(centralTenantName)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenantId: '#(universityTenantUuid)', tenant: '#(universityTenantName)', user: '#(universityUser)' }

    * call postUser { tenant: '#(centralTenantName)', user: '#(centralUser)' }
    * call putCaps { tenant: '#(centralTenantName)', user: '#(centralUser)' }

  Scenario: Setup Consortia
    # 1. Create Consortia
    * def result = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('classpath:utils/consortium.feature@SetupConsortia') { token: '#(result.okapitoken)', tenant: '#(centralTenant)' }
    # 2. Add 2 tenants to consortium
    * call read('classpath:utils/tenant.feature') { token: '#(result.okapitoken)', centralTenantName: '#(centralTenantName)', uniTenant: '#(universityTenant)', consortiaAdmin: '#(consortiaAdmin)' }

    # 3. Add permissions to consortia_admin
    # Permissions for shadowConsortiaAdmin (consortia_admin in university tenant)
    * table userPermissions
      | name                                                        |
      | 'circulation.requests.item.get'                             |
      | 'circulation.requests.item.post'                            |
      | 'circulation.rules.put'                                     |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.collection.get' |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.collection.get'       |
      | 'circulation-storage.request-policies.item.post'            |
      | 'configuration.entries.collection.get'                      |
      | 'configuration.entries.item.get'                            |
      | 'configuration.entries.item.post'                           |
      | 'configuration.entries.item.put'                            |
      | 'consortia.sharing-instances.collection.get'                |
      | 'consortia.sharing-instances.item.post'                     |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.delete'                           |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.item.post'                                 |
      | 'inventory.items.item.delete'                               |
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.hrid-settings.item.get'                  |
      | 'inventory-storage.hrid-settings.item.put'                  |
      | 'inventory-storage.instance-statuses.item.post'             |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.item.post'                |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'patron.account.item-allowed-service-points.item.get'       |
      | 'patron.account.instance-allowed-service-points.item.get'   |
      | 'tlr.settings.get'                                          |
      | 'tlr.settings.put'                                          |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.post'                          |
      | 'consortia.user-tenants.item.delete'                        |
      | 'consortia.user-tenants.item.get'                           |
      | 'consortium-search.items.item.get'                          |
      | 'patron.account.item-hold.item.post'                        |
      | 'patron.account.instance-hold.item.post'                    |

    * call getAuthorizationToken { tenant: '#(universityTenantName)' }
    * def shadowConsortiaAdmin = { id: '#(centralAdminId)', tenant: '#(universityTenantName)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenantName)', user: '#(shadowConsortiaAdmin)' }

  Scenario: Prepare data
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('classpath:utils/inventory.feature')
    * call read('classpath:utils/inventory-university.feature')
    * call read('classpath:utils/configuration.feature')

    # Create test user early to ensure mod-search cache is populated with real users before consortium calls
    * def testGroupId = java.util.UUID.randomUUID().toString()
    * def testGroup = 'lib'
    * def testTenantId = centralTenantName
    * call read('classpath:reusable/user-init-data.feature@CreateGroup') { id: '#(testGroupId)', group: '#(testGroup)', tenantId: '#(testTenantId)' }

    * def testUserId = java.util.UUID.randomUUID().toString()
    * def randomMillisValue = callonce randomMillis
    * def testUserBarcode = 'BG-USER-' + randomMillisValue
    * def testUserName = testUserBarcode
    * def testFirstName = 'BackgroundFirst'
    * def testLastName = 'BackgroundLast'
    * def testExternalId = java.util.UUID.randomUUID().toString()
    * def testPatronId = testGroupId
    * call read('classpath:reusable/user-init-data.feature@CreateUser') { userId: '#(testUserId)', firstName: '#(testFirstName)', lastName: '#(testLastName)', userBarcode: '#(testUserBarcode)', userName: '#(testUserName)', externalId: '#(testExternalId)', patronId: '#(testPatronId)' }

    # 5. Disable instance matching in university tenant
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * configure headers = headersUni
