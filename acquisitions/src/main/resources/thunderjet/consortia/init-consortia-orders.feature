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
      | 'configuration.entries.item.post'                           |
      | 'finance.budgets.collection.get'                            |
      | 'finance.budgets.item.post'                                 |
      | 'finance.expense-classes.item.post'                         |
      | 'finance.fiscal-years.item.post'                            |
      | 'finance.funds.item.post'                                   |
      | 'finance.ledgers.item.post'                                 |
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
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.move.item.post'                            |
      | 'inventory.tenant-items.collection.get'                     |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'orders.acquisition-method.item.post'                       |
      | 'orders.bind-pieces.collection.post'                        |
      | 'orders.bind-pieces.item.delete'                            |
      | 'orders.check-in.collection.post'                           |
      | 'orders.item.get'                                           |
      | 'orders.item.post'                                          |
      | 'orders.item.put'                                           |
      | 'orders.item.reopen'                                        |
      | 'orders.item.unopen'                                        |
      | 'orders.piece-requests.collection.get'                      |
      | 'orders.pieces.collection.get'                              |
      | 'orders.pieces.item.delete'                                 |
      | 'orders.pieces.item.get'                                    |
      | 'orders.pieces.item.post'                                   |
      | 'orders.pieces.item.put'                                    |
      | 'orders.po-lines.collection.get'                            |
      | 'orders.po-lines.item.get'                                  |
      | 'orders.po-lines.item.post'                                 |
      | 'orders.po-lines.item.put'                                  |
      | 'orders.receiving.collection.post'                          |
      | 'orders.titles.collection.get'                              |
      | 'orders.titles.item.get'                                    |
      | 'orders.titles.item.post'                                   |
      | 'orders-storage.settings.item.post'                         |
      | 'organizations.organizations.item.post'                     |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'perms.users.get'                                           |
      | 'perms.users.item.put'                                      |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.item.post'                                      |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'users.item.put'                                            |

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity

    # generate names for tenants
    * def random = callonce randomMillis
    * def uuids = callonce uuids 4
    * def centralTenantId = uuids[0]
    * def centralTenantName = 'central' + random
    * def centralTenant = { id : '#(centralTenantId)', name: '#(centralTenantName)' }
    * def universityTenantId = uuids[1]
    * def universityTenantName = 'university' + random
    * def universityTenant = { id : '#(universityTenantId)', name: '#(universityTenantName)' }

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
    * def enableCentralOrdering = read('tenant-utils/consortium.feature@EnableCentralOrdering')
    * def configureAccessTokenTime = read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime')


  @SetupTenants
  Scenario: Create ['central', 'university'] tenants and set up admins
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login-keycloak'        |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-feesfines'             |
      | 'mod-consortia-keycloak'    |

    * call setupTenant { tenantId: '#(centralTenantId)', tenant: '#(centralTenantName)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenantId: '#(universityTenant.id)', tenant: '#(universityTenantName)', user: '#(universityUser)' }

    # Permissions for centralUser
    * table userPermissions
      | name                                                        |
      | 'orders.pieces.collection.get'                              |
      | 'orders.po-lines.item.get'                                  |
      | 'orders.po-lines.item.put'                                  |

    * call postUser { tenant: '#(centralTenantName)', user: '#(centralUser)' }
    * call putCaps { tenant: '#(centralTenantName)', user: '#(centralUser)' }

  @SetupConsortia
  Scenario: Setup Consortia
    # 1. Create Consortia
    * def result = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('tenant-utils/consortium.feature@SetupConsortia') { token: '#(result.okapitoken)', tenant: '#(centralTenant)' }

#     2. Add 2 tenants to consortium
    * call read('tenant-utils/tenant.feature') { token: '#(result.okapitoken)', centralTenantName: '#(centralTenantName)', uniTenant: '#(universityTenant)', consortiaAdmin: '#(consortiaAdmin)' }

#     3. Add permissions to consortia_admin
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
      | 'consortia.sharing-instances.collection.get'                |
      | 'consortia.sharing-instances.item.post'                     |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
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

    * call getAuthorizationToken { tenant: '#(universityTenantName)' }
    * def shadowConsortiaAdmin = { id: '#(centralAdminId)', tenant: '#(universityTenantName)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenantName)', user: '#(shadowConsortiaAdmin)' }

    # 4. Enable central ordering
    * def result = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call enableCentralOrdering { token: '#(result.token)', tenant: '#(centralTenant)' }

    * call configureAccessTokenTime { 'AccessTokenLifespance' : 3600, testTenant: '#(centralTenantName)' }

  @InitData
  Scenario: Prepare data
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * call read('order-utils/inventory.feature')
    * call read('order-utils/inventory-university.feature')
    * call read('order-utils/configuration.feature')
    * call read('order-utils/finances.feature')
    * call read('order-utils/organizations.feature')
    * call read('order-utils/orders.feature')
