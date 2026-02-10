Feature: mod-consortia and mod-bulk-operations integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table modules
      | name                        |
      | 'mod-consortia'             |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-data-import'           |
      | 'mod-bulk-operations'       |

    * table userPermissions
      | name                                                               |
      | 'consortia.all'                                                    |
      | 'addresstypes.item.post'                                  |
      | 'bulk-edit.item.post'                                     |
      | 'bulk-edit.start.item.post'                               |
      | 'bulk-operations.all'                                     |
      | 'bulk-operations.download.item.get'                       |
      | 'bulk-operations.item.content-update.post'                |
      | 'bulk-operations.item.errors.get'                         |
      | 'bulk-operations.item.get'                                |
      | 'bulk-operations.item.inventory.get'                      |
      | 'bulk-operations.item.inventory.put'                      |
      | 'bulk-operations.item.marc-content-update.post'           |
      | 'bulk-operations.item.preview.get'                        |
      | 'bulk-operations.item.start.post'                         |
      | 'bulk-operations.item.upload.post'                        |
      | 'bulk-operations.item.users.get'                          |
      | 'bulk-operations.item.users.put'                          |
      | 'bulk-operations.list-users.collection.get'               |
      | 'configuration.entries.collection.get'                    |
      | 'data-export.job.item.get'                                |
      | 'data-export.job.item.post'                               |
      | 'departments.item.post'                                   |
      | 'inventory-storage.classification-types.item.post'        |
      | 'inventory-storage.contributor-name-types.item.post'      |
      | 'inventory-storage.contributor-types.collection.get'      |
      | 'inventory-storage.holdings-sources.item.get'             |
      | 'inventory-storage.holdings-sources.item.post'            |
      | 'inventory-storage.holdings.collection.get'               |
      | 'inventory-storage.holdings.item.get'                     |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.holdings.item.put'                     |
      | 'inventory-storage.identifier-types.item.post'            |
      | 'inventory-storage.instance-formats.collection.get'       |
      | 'inventory-storage.instance-types.collection.get'         |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.instances.item.post'                   |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.get'                    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.loan-types.item.get'                   |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.statistical-code-types.item.post'      |
      | 'inventory-storage.statistical-codes.item.post'           |
      | 'inventory.instances.collection.get'                      |
      | 'inventory.instances.item.get'                            |
      | 'inventory.instances.item.post'                           |
      | 'inventory.instances.item.put'                            |
      | 'inventory.items.collection.get'                          |
      | 'inventory.items.item.get'                                |
      | 'inventory.items.item.post'                               |
      | 'inventory.items.item.put'                                |
      | 'proxiesfor.item.post'                                    |
      | 'source-storage.records.post'                             |
      | 'source-storage.snapshots.post'                           |
      | 'usergroups.collection.get'                               |
      | 'usergroups.item.get'                                     |
      | 'usergroups.item.post'                                    |
      | 'users.collection.get'                                    |
      | 'users.item.get'                                          |
      | 'users.item.post'                                         |
      | 'users.item.put'                                          |
      | 'source-storage.stream.source-records.collection.get'     |

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

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(centralTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') {tenantId: '#(universityTenantId)'}