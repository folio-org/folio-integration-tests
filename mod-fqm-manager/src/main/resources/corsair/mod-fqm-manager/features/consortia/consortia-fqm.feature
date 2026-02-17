Feature: mod-consortia and mod-fqm-manager integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-consortia'             |
      | 'mod-inventory-storage'     |
      | 'mod-circulation'           |
      | 'mod-circulation-storage'   |
      | 'mod-finance'               |
      | 'mod-fqm-manager'           |
      | 'mod-finance-storage'       |
      | 'mod-orders'                |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |
      | 'mod-tags'                  |



    * table userPermissions
      | name                                                               |
      | 'consortia.all'                                                    |
      | 'inventory.instances.item.get'                                     |
      | 'fqm.entityTypes.collection.get'                                   |
      | 'inventory-storage.alternative-title-types.collection.get'         |
      | 'inventory-storage.call-number-types.collection.get'               |
      | 'inventory-storage.classification-types.collection.get'            |
      | 'inventory-storage.contributor-name-types.collection.get'          |
      | 'inventory-storage.contributor-types.collection.get'               |
      | 'inventory-storage.holdings-sources.item.post'                     |
      | 'inventory-storage.holdings-types.collection.get'                  |
      | 'inventory-storage.holdings.item.get'                              |
      | 'inventory-storage.holdings.item.post'                             |
      | 'inventory-storage.instance-date-types.collection.get'             |
      | 'inventory-storage.instance-statuses.collection.get'               |
      | 'inventory-storage.instance-formats.collection.get'                |
      | 'inventory-storage.instance-types.collection.get'                  |
      | 'inventory-storage.instance-types.item.post'                       |
      | 'inventory-storage.instances.item.get'                             |
      | 'inventory-storage.instances.item.post'                            |
      | 'inventory-storage.items.item.get'                                 |
      | 'inventory-storage.items.item.post'                                |
      | 'inventory-storage.loan-types.item.post'                           |
      | 'inventory-storage.loan-types.collection.get'                      |
      | 'inventory-storage.location-units.campuses.item.post'              |
      | 'inventory-storage.location-units.institutions.item.post'          |
      | 'inventory-storage.location-units.libraries.collection.get'        |
      | 'inventory-storage.location-units.libraries.item.post'             |
      | 'inventory-storage.locations.collection.get'                       |
      | 'inventory-storage.locations.item.post'                            |
      | 'inventory-storage.material-types.collection.get'                  |
      | 'inventory-storage.material-types.item.post'                       |
      | 'inventory-storage.service-points.collection.get'                  |
      | 'inventory-storage.statistical-code-types.collection.get'          |
      | 'inventory-storage.statistical-codes.collection.get'               |
      | 'user-tenants.collection.get'                                      |
      | 'user-tenants.item.post'                                           |
      | 'users.collection.get'                                             |
      | 'inventory-storage.instance-note-types.collection.get'             |
      | 'inventory-storage.holdings-note-types.collection.get'             |
      | 'inventory-storage.electronic-access-relationships.collection.get' |
      | 'inventory-storage.item-note-types.collection.get'                 |
      | 'inventory-storage.identifier-types.collection.get'                |
      | 'inventory-storage.subject-sources.collection.get'                 |
      | 'inventory-storage.subject-types.collection.get'                   |
      | 'inventory-storage.nature-of-content-terms.collection.get'         |
      | 'proxiesfor.collection.get'                                        |
      | 'tags.collection.get'                                              |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c31'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenantId = uuid()
    * def centralTenant = 'central' + random
    * def universityTenantId = uuid()
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdminId = '122b3d2b-4788-4f1e-9117-56daa91cb75d'
    * def consortiaAdmin = { id: '#(consortiaAdminId)', name: 'consortia_admin', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def universityUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521413', username: 'university_user1', name: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}

  Scenario: Consortium api tests
    * call read('consortium.feature')

  Scenario: Tenant api tests
    * call read('tenant.feature')

  Scenario: Cross Tenant
    * call read('cross_tenant_et.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(centralTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(universityTenantId)'}