Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * configure connectTimeout = 600000

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
      | 'finance.ledgers.item.post'                                 |
      | 'finance-storage.funds.item.post'                           |
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
      | 'organizations-storage.organizations.item.post'             |
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
    * def uuids = callonce uuids 6
    * def centralTenantId = uuids[0]
    * def centralTenantName = 'central' + random
    * def centralTenant = {id : '#(centralTenantId)', name: '#(centralTenantName)'}
    * def universityTenantId = uuids[1]
    * def universityTenantName = 'university' + random
    * def universityTenant = {id : '#(universityTenantId)', name: '#(universityTenantName)'}

    * def universityUserId = uuids[2]
    * def centralAdminId = uuids[3]
    * def centralUserId = uuids[4]

    # define consortium
    * def consortiumId = uuids[5]

    # define main users
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant.name)'}
    * def universityUser = { id: '#(universityUserId)', username: 'university_user', password: 'university_user_password', type: 'staff', tenant: '#(universityTenant.name)'}

    * def centralUser = { id: '#(centralUserId)', username: 'central_user', password: 'central_user_password', type: 'staff', tenant: '#(centralTenant.name)'}

  @SetupTenants
  Scenario: Create ['central', 'university'] tenants and set up admins
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login-keycloack'       |
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
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenantId: '#(centralTenant.id)', tenant: '#(centralTenant.name)', user: '#(consortiaAdmin)'}

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login-keycloack'       |
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
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenantId: '#(universityTenant.id)', tenant: '#(universityTenant.name)', user: '#(universityUser)'}

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
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory.holdings.move.item.post'                         |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'inventory.instances.item.get'                              |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.move.item.post'                            |
      | 'inventory.tenant-items.collection.get'                     |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'orders.bind-pieces.collection.post'                        |
      | 'orders.bind-pieces.item.delete'                            |
      | 'orders.check-in.collection.post'                           |
      | 'orders.collection.get'                                     |
      | 'orders.expect.collection.post'                             |
      | 'orders.holding-summary.collection.get'                     |
      | 'orders.item.delete'                                        |
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
      | 'orders.po-lines.fund-distributions.validate'               |
      | 'orders.po-lines.item.delete'                               |
      | 'orders.po-lines.item.get'                                  |
      | 'orders.po-lines.item.post'                                 |
      | 'orders.po-lines.item.put'                                  |
      | 'orders.po-number.item.get'                                 |
      | 'orders.po-number.item.post'                                |
      | 'orders.re-encumber.item.post'                              |
      | 'orders.receiving.collection.post'                          |
      | 'orders.receiving-history.collection.get'                   |
      | 'orders.rollover.item.post'                                 |
      | 'orders.titles.collection.get'                              |
      | 'orders.titles.item.get'                                    |
      | 'orders.titles.item.post'                                   |
      | 'orders-storage.settings.item.post'                         |
      | 'usergroups.item.post'                                      |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'users.item.put'                                            |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |

    * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {tenant: '#(centralTenant.name)', user: '#(centralUser)'}
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {tenant: '#(centralTenant.name)', user: '#(centralUser)'}

  @SetupConsortia
  Scenario: Setup Consortia
    # 1. Create Consortia
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    * call read('tenant-utils/consortium.feature@SetupConsortia') {token: '#(result.okapitoken)', tenant: '#(centralTenant)'}

#     2. Add 2 tenants to consortium
    * call read('tenant-utils/tenant.feature') {token: '#(result.okapitoken)', centralTenantName: '#(centralTenant.name)', uniTenant: '#(universityTenant)', consortiaAdmin: '#(consortiaAdmin)'}

#     3. Add permissions to consortia_admin
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
      | 'consortia.consortia-configuration.item.delete'             |
      | 'consortia.consortia-configuration.item.post'               |
      | 'consortia.consortium.item.get'                             |
      | 'consortia.consortium.item.post'                            |
      | 'consortia.consortium.item.put'                             |
      | 'consortia.create-primary-affiliations.item.post'           |
      | 'consortia.custom-login.item.post'                          |
      | 'consortia.identity-provider.item.delete'                   |
      | 'consortia.identity-provider.item.post'                     |
      | 'consortia.inventory.local.sharing-instances.execute'       |
      | 'consortia.inventory.update-ownership.item.post'            |
      | 'consortia.publications-results.item.get'                   |
      | 'consortia.publications.item.delete'                        |
      | 'consortia.publications.item.get'                           |
      | 'consortia.publications.item.post'                          |
      | 'consortia.sharing-instances.collection.get'                |
      | 'consortia.sharing-instances.item.get'                      |
      | 'consortia.sharing-instances.item.post'                     |
      | 'consortia.sharing-policies.item.delete'                    |
      | 'consortia.sharing-policies.item.post'                      |
      | 'consortia.sharing-roles-all.item.delete'                   |
      | 'consortia.sharing-roles-all.item.post'                     |
      | 'consortia.sharing-roles-capabilities.item.delete'          |
      | 'consortia.sharing-roles-capabilities.item.post'            |
      | 'consortia.sharing-roles-capability-sets.item.delete'       |
      | 'consortia.sharing-roles-capability-sets.item.post'         |
      | 'consortia.sharing-roles.item.delete'                       |
      | 'consortia.sharing-roles.item.post'                         |
      | 'consortia.sharing-settings.item.delete'                    |
      | 'consortia.sharing-settings.item.post'                      |
      | 'consortia.sync-primary-affiliations.item.post'             |
      | 'consortia.tenants.item.delete'                             |
      | 'consortia.tenants.item.get'                                |
      | 'consortia.tenants.item.post'                               |
      | 'consortia.tenants.item.put'                                |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.delete'                        |
      | 'consortia.user-tenants.item.get'                           |
      | 'consortia.user-tenants.item.post'                          |
      | 'finance-storage.funds.item.post'                           |
      | 'finance.budgets.collection.get'                            |
      | 'finance.budgets.item.post'                                 |
      | 'finance.expense-classes.item.post'                         |
      | 'finance.fiscal-years.item.post'                            |
      | 'finance.ledgers.item.post'                                 |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory-storage.holdings.collection.get'                 |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.instance-statuses.item.post'             |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items-by-holdings-id.collection.get'             |
      | 'inventory.items.collection.get'                            |
      | 'inventory.items.item.delete'                               |
      | 'inventory.items.item.get'                                  |
      | 'inventory.items.move.item.post'                            |
      | 'inventory.tenant-items.collection.get'                     |
      | 'inventory.holdings.move.item.post'                         |
      | 'inventory.holdings.update-ownership.item.post'             |
      | 'lost-item-fees-policies.collection.get'                    |
      | 'lost-item-fees-policies.item.post'                         |
      | 'orders.acquisition-method.item.post'                       |
      | 'orders.bind-pieces.collection.post'                        |
      | 'orders.bind-pieces.item.delete'                            |
      | 'orders.check-in.collection.post'                           |
      | 'orders.item.post'                                          |
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
      | 'orders-storage.settings.item.post'                         |
      | 'orders.titles.collection.get'                              |
      | 'orders.titles.item.get'                                    |
      | 'orders.titles.item.post'                                   |
      | 'organizations-storage.organizations.item.post'             |
      | 'overdue-fines-policies.collection.get'                     |
      | 'overdue-fines-policies.item.post'                          |
      | 'perms.users.get'                                           |
      | 'perms.users.item.put'                                      |
      | 'tags.collection.get'                                       |
      | 'tags.item.delete'                                          |
      | 'tags.item.get'                                             |
      | 'tags.item.post'                                            |
      | 'tags.item.put'                                             |
      | 'user-tenants.collection.get'                               |
      | 'usergroups.item.post'                                      |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'users.item.put'                                            |

    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken') {tenant: '#(universityTenant.name)'}
    * def shadowConsortiaAdmin = { id: '#(centralAdminId)', tenant: '#(universityTenant.name)'}
    * configure cookies = null
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {tenant: '#(universityTenant.name)', user: '#(shadowConsortiaAdmin)'}

    # 4. Enable central ordering
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    * call read('tenant-utils/consortium.feature@EnableCentralOrdering') {token: '#(result.token)', tenant: '#(centralTenant)'}

    * call read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime') { 'AccessTokenLifespance' : 1800, testTenant: '#(centralTenant.name)' }

  @InitData
  Scenario: Prepare data
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    * call read('order-utils/inventory.feature') {token: '#(result.okapitoken)', tenant: '#(centralTenant)'}
    * call read('order-utils/inventory-university.feature') {token: '#(result.okapitoken)', tenant: '#(universityTenant)'}
    * call read('order-utils/configuration.feature') {token: '#(result.okapitoken)', tenant: '#(centralTenant)'}
    * call read('order-utils/finances.feature') {token: '#(result.okapitoken)', tenant: '#(centralTenant)'}
    * call read('order-utils/organizations.feature') {okapitoken: '#(result.okapitoken)', tenantName: '#(centralTenant.name)'}
    * call read('order-utils/orders.feature') {token: '#(result.okapitoken)', tenant: '#(centralTenant)'}

  Scenario: Open order with locations from different tenants
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    Given call read('features/open-order-with-locations-from-different-tenants.feature') {okapitoken: '#(result.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant)'}

  Scenario: Reopen order and change instance connection orderLine
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    Given call read('features/reopen-and-change-instance-connection-order-with-locations-from-different-tenants.feature') {okapitoken: '#(result.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)'}

  Scenario: Performance Open order wtih many locations from different tenants
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    Given call read('features/prf-open-order-with-many-locations-from-different-tenants.feature') {okapitoken: '#(result.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)'}

  Scenario: Piece Api Test for cross tenant envs
    * def resultAdmin = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    * def resultUniAdmin = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenant.name)'}
    * def resultUser = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(centralUser.username)', password: '#(centralUser.password)', tenant: '#(centralTenant.name)'}
    Given call read("features/pieces-api-test-for-cross-tenant-envs.feature") {okapitoken: '#(resultAdmin.okapitoken)', okapitokenUser: '#(resultUser.okapitoken)', okapitokenUni: '#(resultUniAdmin.okapitoken)' , centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)', centralAdminId: '#(centralAdminId)', universityUserId: '#(universityUserId)', universityUser: '#(universityUser)'}

  Scenario: Bind pieces features in ECS environment
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    Given call read("features/bind-pieces-ecs.feature") {okapitoken: '#(result.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)'}

  Scenario: Update unaffiliated PoLine locations
    * def resultAdmin = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    * def resultUser = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(centralUser.username)', password: '#(centralUser.password)', tenant: '#(centralTenant.name)'}
    Given call read("features/update-unaffiliated-pol-locations.feature") {okapitoken: '#(resultAdmin.okapitoken)', okapitokenUser: '#(resultUser.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)', centralAdminId: '#(centralAdminId)', universityUserId: '#(universityUserId)', universityUser: '#(universityUser)'}

  Scenario: Update inventory ownership changes order data
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant.name)'}
    Given call read("features/update-inventory-ownership-changes-order-data.feature") {okapitoken: '#(result.okapitoken)', centralTenant: '#(centralTenant.name)', universityTenant: '#(universityTenant.name)'}

  Scenario: Move Item and Holding to update order data in ECS environment
    Given call read("features/mode-item-and-holding-to-update-order-data-ecs.feature") {consortiaAdmin: '#(consortiaAdmin)', centralTenant: '#(centralTenant.name)'}

  @DestroyData
  Scenario: Destroy created ['central', 'university'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantId: '#(universityTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantId: '#(centralTenantId)'}
