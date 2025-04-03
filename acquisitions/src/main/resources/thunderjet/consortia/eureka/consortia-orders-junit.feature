Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000

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
      | 'mod-consortia-keycloak' |

    * table adminAdditionalPermissions
      | name                                         |
      | 'overdue-fines-policies.item.post'           |
      | 'lost-item-fees-policies.item.post'          |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post'   |
      | 'acquisitions-units.units.item.post'         |
      |'circulation.check-out-by-barcode.post'|
      |'circulation.check-in-by-barcode.post'|
      |'circulation.renew-by-barcode.post'|
      |'circulation.renew-by-id.post'|
      |'circulation.loans.collection.get'|
      |'circulation.loans.item.get'|
      |'circulation.loans.item.post'|
      |'circulation.loans.item.put'|
      |'circulation.loans.item.delete'|
      |'circulation.loans.collection.delete'|
      |'circulation.loans.change-due-date.post'|
      |'circulation.loans.add-info.post'|
      |'circulation.loans.claim-item-returned.post'|
      |'circulation.loans.declare-claimed-returned-item-as-missing.post'|
      |'circulation.rules.put'|
      |'circulation.rules.get'|
      |'circulation.rules.loan-policy.get'|
      |'circulation.rules.loan-policy-all.get'|
      |'circulation.rules.request-policy.get'|
      |'circulation.rules.request-policy-all.get'|
      |'circulation.rules.notice-policy.get'|
      |'circulation.rules.notice-policy-all.get'|
      |'circulation.requests.collection.get'|
      |'circulation.requests.item.get'|
      |'circulation.requests.item.post'|
      |'circulation.requests.item.put'|
      |'circulation.requests.item.delete'|
      |'circulation.requests.item.move.post'|
      |'circulation.requests.collection.delete'|
      |'circulation.requests.queue-instance.collection.get'|
      |'circulation.requests.queue-item.collection.get'|
      |'circulation.requests.queue.reorder.collection.post'|
      |'circulation.requests.instances.item.post'|
      |'circulation.requests.hold-shelf-clearance-report.get'|
      |'circulation.requests.allowed-service-points.get'|
      |'circulation.inventory.items-in-transit-report.get'|
      |'circulation.pick-slips.get'|
      |'circulation.search-slips.get'|
      |'circulation.handlers.loan-related-fee-fine-closed.post'|
      |'circulation.handlers.fee-fine-balance-changed.post'|
      |'circulation.items-by-instance.get'|
      |'consortia.tenants.item.post'|
      |'consortia.tenants.item.put'|
      |'consortia.tenants.item.delete'|
      |'consortia.tenants.item.get'|
      |'consortia.user-tenants.collection.get'|
      |'consortia.user-tenants.item.get'|
      |'consortia.consortium.item.post'|
      |'consortia.consortium.item.put'|
      |'consortia.consortium.item.get'|
      |'consortia.user-tenants.item.post'|
      |'consortia.user-tenants.item.delete'|
      |'consortia.consortia-configuration.item.post'|
      |'consortia.consortia-configuration.item.delete'|
      |'consortia.inventory.local.sharing-instances.execute'|
      |'consortia.inventory.update-ownership.item.post'|
      |'consortia.sync-primary-affiliations.item.post'|
      |'consortia.create-primary-affiliations.item.post'|
      |'consortia.identity-provider.item.post'|
      |'consortia.identity-provider.item.delete'|
      |'consortia.custom-login.item.post'|
      |'consortia.sharing-instances.item.post'|
      |'consortia.sharing-instances.item.get'|
      |'consortia.sharing-instances.collection.get'|
      |'consortia.publications.item.post'|
      |'consortia.publications.item.get'|
      |'consortia.publications.item.delete'|
      |'consortia.publications-results.item.get'|
      |'consortia.sharing-settings.item.post'|
      |'consortia.sharing-settings.item.delete'|
      |'consortia.sharing-policies.item.post'|
      |'consortia.sharing-policies.item.delete'|
      |'consortia.sharing-roles.item.post'|
      |'consortia.sharing-roles.item.delete'|
      |'consortia.sharing-roles-capability-sets.item.post'|
      |'consortia.sharing-roles-capability-sets.item.delete'|
      |'consortia.sharing-roles-capabilities.item.post'|
      |'consortia.sharing-roles-capabilities.item.delete'|
      |'orders.collection.get'|
      |'orders.item.post'|
      |'orders.item.get'|
      |'orders.item.put'|
      |'orders.item.delete'|
      |'orders.po-lines.collection.get'|
      |'orders.po-lines.item.post'|
      |'orders.po-lines.item.get'|
      |'orders.po-lines.item.put'|
      |'orders.po-lines.item.delete'|
      |'orders.po-lines.item.patch'|
      |'orders.po-lines.fund-distributions.validate'|
      |'orders.po-number.item.get'|
      |'orders.po-number.item.post'|
      |'orders.receiving.collection.post'|
      |'orders.check-in.collection.post'|
      |'orders.expect.collection.post'|
      |'orders.receiving-history.collection.get'|
      |'orders.re-encumber.item.post'|
      |'orders.rollover.item.post'|
      |'orders.holding-summary.collection.get'|
      |'orders-storage.settings.collection.get'|
      |'orders-storage.settings.item.get'|
      |'orders-storage.settings.item.post'|
      |'orders-storage.settings.item.put'|
      |'orders-storage.settings.item.delete'|
      | 'okapi.proxy.tenants.modules.list' |


    * table userPermissions
      | name                                        |
      |'orders.collection.get'|
      |'orders.item.post'|
      |'orders.item.get'|
      |'orders.item.put'|
      |'orders.item.delete'|
      |'orders.po-lines.collection.get'|
      |'orders.po-lines.item.post'|
      |'orders.po-lines.item.get'|
      |'orders.po-lines.item.put'|
      |'orders.po-lines.item.delete'|
      |'orders.po-lines.item.patch'|
      |'orders.po-lines.fund-distributions.validate'|
      |'orders.po-number.item.get'|
      |'orders.po-number.item.post'|
      |'orders.receiving.collection.post'|
      |'orders.check-in.collection.post'|
      |'orders.expect.collection.post'|
      |'orders.receiving-history.collection.get'|
      |'orders.re-encumber.item.post'|
      |'orders.rollover.item.post'|
      |'orders.holding-summary.collection.get'|

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenantId = call uuid
    * def centralTenantName = 'central' + random
    * def centralTenant = {id : '#(centralTenantId)', name: '#(centralTenantName)'}
    * def universityTenantId = call uuid
    * def universityTenantName = 'university' + random
    * def universityTenant = {id : '#(universityTenantId)', name: '#(universityTenantName)'}

    * def universityUser1Id = call uuid3
    * def centralAdminId = call uuid3
    * def centralUser1Id = call uuid3

    # define consortium
    * def consortiumId = call uuid12

    # define main users
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant.name)'}
    * def universityUser1 = { id: '#(universityUser1Id)', username: 'university_user1', password: 'university_user1_password', type: 'staff', tenant: '#(universityTenant.name)'}

    * def centralUser1 = { id: '#(centralUser1Id)', username: 'central_user1', password: 'central_user1_password', type: 'staff', tenant: '#(centralTenant.name)'}
    * def centralUser1Perms = $userPermissions[*].name
    * def centralUser1PermsDetails = { id: '#(centralUser1Id)', extPermissions: '#(centralUser1Perms)', tenant: '#(centralTenant)'}

  @SetupTenants
  Scenario: Create ['central', 'university'] tenants and set up admins
    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(masterClient)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)', token: '#(result.token)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)', token: '#(result.token)'}

    # add 'consortia.all' (for consortia management)
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {tenant: '#(centralTenant)', client: '#(masterClient)'}
#    * def testClient = {secret: '#(result.sidecarSecret)', realm: '#(centralTenant.name)', id: 'sidecar-module-access-client'}
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(testClient)'}
#    * def token = result.token
#    * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {user: '#(consortiaAdmin)', token: '#(token)', tenant: '#(centralTenant)'}
#    * def capNames = $adminAdditionalPermissions[*].name
#    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {user: '#(consortiaAdmin)', token: '#(token)', capNames: '#(capNames)'}
#
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {tenant: '#(universityTenant)', client: '#(masterClient)'}
#    * def testClient = {secret: '#(result.sidecarSecret)', realm: '#(universityTenant.name)', id: 'sidecar-module-access-client'}
#    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(testClient)'}
#    * def token = result.token
#    * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {user: '#(universityUser1)', token: '#(token)', tenant: '#(universityTenant)'}
#    * def adminAdditionalPermissions = $adminAdditionalPermissions[*].name
#    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {user: '#(universityUser1)', token: '#(token)', capNames: '#(capNames)'}

    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@NewTenantToken') {tenant: '#(centralTenant)', client: '#(masterClient)'}
    * def testClient = {secret: '#(result.sidecarSecret)', realm: '#(centralTenant.name)', id: 'sidecar-module-access-client'}
    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(testClient)'}
    * def token = result.token
    * call read('classpath:common-consortia/eureka/initData.feature@PostUser') {user: '#(centralUser1)', token: '#(token)', tenant: '#(centralTenant)'}
    * def capNames = $userPermissions[*].name
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') {user: '#(centralUser1)', token: '#(token)', capNames: '#(capNames)'}

  @SetupConsortia
  Scenario: Setup Consortia
    # 1. Create Consortia
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { user: '#(consortiaAdmin)'}
    * call read('tenant-utils/consortium.feature@CreateConsortium') {token: '#(result.token)', tenant: '#(centralTenant)'}

    # 2. Add 2 tenants to consortium
    * call read('tenant-utils/tenant.feature') {token: '#(result.token)', tenant: '#(centralTenant)', uniTenant: '#(universityTenant)'}

    # 4. Enable central ordering
    * call read('tenant-utils/consortium.feature@EnableCentralOrdering') {token: '#(result.token)', tenant: '#(centralTenant)'}

#  @InitData
#  Scenario: Prepare data
    * def result = call read('classpath:common-consortia/eureka/initData.feature@Login') { user: '#(consortiaAdmin)'}
#    * call read('order-utils/inventory.feature') {token: '#(result.token)', tenant: '#(centralTenant)'}
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
#
  @DestroyData
  Scenario: Destroy created ['central', 'university'] tenants
    * def result = call read('classpath:common-consortia/eureka/keycloack.feature@Login') {client: '#(masterClient)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenant') { tenant: '#(universityTenant)', token: '#(result.token)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenant') { tenant: '#(centralTenant)', token: '#(result.token)'}
