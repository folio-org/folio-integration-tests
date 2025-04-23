# Please refer to the following document to see test cases for 'mod-consortia':
# https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

Feature: mod-consortia and mod-data-export integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'okapi'                     |

    * table userPermissions
      | name                                            |
      | 'data-export.file-definitions.item.post'        |
      | 'data-export.file-definitions.item.get'         |
      | 'data-export.file-definitions.upload.post'      |
      | 'data-export.export.post'                       |
      | 'data-export.job-executions.item.delete'        |
      | 'data-export.job-executions.items.download.get' |
      | 'data-export.logs.collection.get'               |
      | 'inventory.instances.item.post'                 |
      | 'source-storage.snapshots.post'                 |
      | 'source-storage.records.post'                   |
      | 'inventory.instances.item.get'                  |
      | 'data-export.job-executions.collection.get'     |
      | 'user-tenants.collection.get'                   |
      | 'user-tenants.item.post'                        |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenantId = uuid()
    * def centralTenant = 'central' + random
    * def universityTenantId = uuid()
    * def universityTenant = 'university' + random

    # define users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}
    * pause(5000)

  Scenario: Consortium api tests
    * call read('consortia/consortium.feature')

  Scenario: Tenant api tests
    * call read('consortia/tenant.feature')

  Scenario: Sharing Instances api tests
    * call read('consortia/sharing-instance.feature')

  Scenario: Data export in consortia
    * call read('consortia/export.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(centralTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(universityTenantId)'}