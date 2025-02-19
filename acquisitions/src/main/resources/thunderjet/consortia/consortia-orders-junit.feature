Feature: mod-consortia integration tests

  Background:
    * url kongUrl
    * configure readTimeout = 600000
    * configure retry = { count: 20, interval: 40000 }
    * def requiredModules = ['mod-permissions', 'mod-configuration', 'mod-login-keycloak', 'mod-users', 'mod-pubsub', 'mod-audit', 'mod-orders-storage', 'mod-orders', 'mod-invoice-storage', 'mod-invoice', 'mod-finance-storage', 'mod-finance', 'mod-organizations-storage', 'mod-organizations', 'mod-inventory-storage', 'mod-inventory', 'mod-circulation-storage', 'mod-circulation', 'mod-feesfines']

    * def adminAdditionalCaps = ['orders-storage.module.all', 'finance.module.all', 'circulation.all', 'overdue-fines-policies.item.post', 'lost-item-fees-policies.item.post', 'acquisitions-units.memberships.item.delete', 'acquisitions-units.memberships.item.post', 'acquisitions-units.units.item.post']

    * def userCaps = ['orders.all']

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenantId = callonce uuid
    * def centralTenantName = 'central' + random
    * def centralTenant = {id: '#(centralTenantId)', name: '#(centralTenantName)'}
    * def universityTenantId = callonce uuid
    * def universityTenantName = 'university' + random
    * def universityTenant = {id: '#(universityTenantId)', name: '#(universityTenantName)'}

    * def universityUser1Id = callonce uuid3

    # define consortium
    * def consortiumId = callonce uuid12

    # define main users
    * def consortiaAdmin = karate.get('test_admin')
    * def universityUser = karate.get('test_user')
    * def centralUser = karate.get('test_user')

  @SetupTenants
  Scenario: Create ['central', 'university'] tenants and set up admins
    * def centralClient = karate.get('testCentralClient')
    * def master_client = karate.get('masterClient')
    * print 'Setting up tenant: ' + '#(centralTenant)'
    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(master_client)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', modules: '#(requiredModules)', testClient: '#(centralClient)', adminUser: '#(consortiaAdmin)', testUser: '#(centralUser)', token: '#(result.token)'}
    * def universityClient = karate.get('testUniversityClient')
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant')  { tenant: '#(universityTenant)', modules: '#(requiredModules)', testClient: '#(universityClient)', adminUser: '#(consortiaAdmin)', testUser: '#(universityUser)', token: '#(result.token)'}

#     add 'consortia.all' (for consortia management)
    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/initData.feature@PutCaps') { tenant: '#(centralTenant)', modules: '#(requiredModules)', testClient: '#(centralClient)', token: '#(result.token)'}

    * call read('classpath:common-consortia/initData.feature@PostUser') {tenant: '#(centralTenant)', user: '#(centralUser)', token: '#(result.token)'}
    * call read('classpath:common-consortia/initData.feature@PutCaps') {user: '#(centralUser)', tenant: '#(centralTenant)', token: '#(result.token)', capNames: '#(userCaps)'}

    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {user: '#(universityUser)'}
    * call read('classpath:common-consortia/initData.feature@PutCaps') {user: '#(universityUser)', tenant: '#(universityTenant)', token: '#(result.token)', capNames: ['consortia.all']}

  @SetupConsortia
  Scenario: Setup Consortia
    # 1. Create Consortia
    * call read('tenant-utils/consortium.feature@CreateConsortium')

    # 2. Add 2 tenants to consortium
    * call read('tenant-utils/tenant.feature')

    # 3. Add permissions to consortia_admin
    * call read('tenant-utils/add-permissions-for-admin.feature')

    # 4. Enable central ordering
    * call read('tenant-utils/consortium.feature@EnableCentralOrdering')
#
#  @InitData
#  Scenario: Prepare data
#    * call read('order-utils/inventory.feature')
#    * call read('order-utils/inventory-university.feature')
#    * call read('order-utils/configuration.feature')
#    * call read('order-utils/finances.feature')
#    * call read('order-utils/organizations.feature')
#    * call read('order-utils/orders.feature')
#
#  Scenario: Open order with locations from different tenants
#    Given call read('features/open-order-with-locations-from-different-tenants.feature')
#
#  Scenario: Reopen order and change instance connection orderLine
#    Given call read('features/reopen-and-change-instance-connection-order-with-locations-from-different-tenants.feature')
#
#  Scenario: Performance Open order wtih many locations from different tenants
#    Given call read('features/prf-open-order-with-many-locations-from-different-tenants.feature')
#
#  Scenario: Piece Api Test for cross tenant envs
#    Given call read("features/pieces-api-test-for-cross-tenant-envs.feature")
#
#  Scenario: Bind pieces features in ECS environment
#    Given call read("features/bind-pieces-ecs.feature")
#
#  Scenario: Update unaffiliated PoLine locations
#    Given call read("features/update-unaffiliated-pol-locations.feature")
#
#  Scenario: Update inventory ownership changes order data
#    Given call read("features/update-inventory-ownership-changes-order-data.feature")
#
#  Scenario: Move Item and Holding to update order data in ECS environment
#    Given call read("features/mode-item-and-holding-to-update-order-data-ecs.feature")

  @DestroyData
  Scenario: Destroy created ['central', 'university'] tenants
    * def master_client = karate.get('masterClient')
    * def result = call read('classpath:common-consortia/keycloack.feature@Login') {client: '#(master_client)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)', token: '#(result.token)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)', token: '#(result.token)'}
