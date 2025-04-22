Feature: mod-consortia and mod-lists integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-users'               |
      | 'mod-circulation-storage' |
      | 'mod-fqm-manager'         |
      | 'mod-lists'               |
      | 'mod-entities-links'      |

    * table userPermissions
      | name                                                        |
      | 'circulation-storage.loan-policies.collection.get'          |
      | 'circulation.loans.collection.get'                          |
      | 'departments.collection.get'                                |
      | 'inventory-storage.call-number-types.collection.get'        |
      | 'inventory-storage.classification-types.collection.get'     |
      | 'inventory-storage.contributor-name-types.collection.get'   |
      | 'inventory-storage.contributor-types.collection.get'        |
      | 'inventory-storage.holdings.item.get'                       |
      | 'inventory-storage.instance-date-types.collection.get'      |
      | 'inventory-storage.instance-formats.collection.get'         |
      | 'inventory-storage.instances.item.get'                      |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.location-units.libraries.collection.get' |
      | 'inventory-storage.locations.collection.get'                |
      | 'inventory-storage.material-types.collection.get'           |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.statistical-code-types.collection.get'   |
      | 'inventory-storage.statistical-codes.collection.get'        |
      | 'inventory-storage.loan-types.collection.get'               |
      | 'usergroups.collection.get'                                 |
      | 'users.collection.get'                                      |
      | 'users.item.delete'                                         |
      | 'users.item.get'                                            |
      | 'users.item.post'                                           |
      | 'lists.collection.get'                                      |
      | 'lists.collection.post'                                     |
      | 'lists.item.contents.get'                                   |
      | 'lists.item.delete'                                         |
      | 'lists.item.export.download.get'                            |
      | 'lists.item.export.get'                                     |
      | 'lists.item.export.post'                                    |
      | 'lists.item.get'                                            |
      | 'lists.item.post'                                           |
      | 'lists.item.refresh.cancel'                                 |
      | 'lists.item.update'                                         |
      | 'lists.item.versions.collection.get'                        |
      | 'lists.item.versions.item.get'                              |
      | 'user-tenants.collection.get'                               |
      | 'user-tenants.item.post'                                    |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c31'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenantId = uuid()
    * def centralTenant = 'central' + random
    * def universityTenantId = uuid()
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def universityUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}

  Scenario: Consortium api tests
    * call read('consortium.feature')

  Scenario: Tenant api tests
    * call read('tenant.feature')

  Scenario: Export
    * call read('ecs-export.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(centralTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(universityTenantId)'}