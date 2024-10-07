Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * call login admin

    * table requiredModules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login'                 |
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

    * table adminAdditionalPermissions
      | name                                         |
      | 'orders-storage.module.all'                  |
      | 'finance.module.all'                         |
      | 'circulation.all'                            |
      | 'overdue-fines-policies.item.post'           |
      | 'lost-item-fees-policies.item.post'          |
      | 'acquisitions-units.memberships.item.delete' |
      | 'acquisitions-units.memberships.item.post'   |
      | 'acquisitions-units.units.item.post'         |

    * table userPermissions
      | name                                        |
      | 'orders.all'                                |

    # load global variables
    * callonce variables
    # load central tenant variables
    * callonce variablesCentral
    # load university tenant variables
    * callonce variablesUniversity

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    * def universityUser1Id = callonce uuid3

    # define consortium
    * def consortiumId = callonce uuid12

    # define main users
    * def consortiaAdmin = { id: '#(centralAdminId)', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}
    * def universityUser1 = { id: '#(universityUser1Id)', username: 'university_user1', password: 'university_user1_password', type: 'staff', tenant: '#(universityTenant)'}

    * def centralUser1 = { id: '#(centralUser1Id)', username: 'central_user1', password: 'central_user1_password', type: 'staff', tenant: '#(centralTenant)'}
    * def centralUser1Perms = $userPermissions[*].name
    * def centralUser1PermsDetails = { id: '#(centralUser1Id)', extPermissions: '#(centralUser1Perms)', tenant: '#(centralTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/initData.feature@Login')

  @SetupTenants
  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}

    # add 'consortia.all' (for consortia management)
    * call login consortiaAdmin
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

    * call read('classpath:common-consortia/initData.feature@PostUser') centralUser1
    * call read('classpath:common-consortia/initData.feature@PostPermissions') centralUser1PermsDetails

    * call login universityUser1
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

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

  @InitData
  Scenario: Prepare data
    * call read('order-utils/inventory.feature')
    * call read('order-utils/inventory-university.feature')
    * call read('order-utils/configuration.feature')
    * call read('order-utils/finances.feature')
    * call read('order-utils/organizations.feature')
    * call read('order-utils/orders.feature')

  Scenario: Open order with locations from different tenants
    Given call read('features/open-order-with-locations-from-different-tenants.feature')

  Scenario: Reopen order and change instance connection orderLine
    Given call read('features/reopen-and-change-instance-connection-order-with-locations-from-different-tenants.feature')

  Scenario: Performance Open order wtih many locations from different tenants
    Given call read('features/prf-open-order-with-many-locations-from-different-tenants.feature')

  Scenario: Piece Api Test for cross tenant envs
    Given call read("features/pieces-api-test-for-cross-tenant-envs.feature")

  Scenario: Bind pieces features in ECS environment
    Given call read("features/bind-pieces-ecs.feature")

  Scenario: Update unaffiliated PoLine locations
    Given call read("features/update-unaffiliated-pol-locations.feature")

  @DestroyData
  Scenario: Destroy created ['central', 'university'] tenants
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
