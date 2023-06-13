Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table requiredModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
    # following modules will also be enabled:
    # | 'mod-tags'                  |
    # | 'mod-users'                 |
    # | 'folio_users'               |
    # | 'mod-users-bl'              |
    # | 'mod-consortia'             |
    # | 'mod-authtoken'             |
    # | 'mod-password-validator'    |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'
    * def consortiaSystemUserName = 'consortia-system-user'

    # generate test tenants' names
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    # define users
    * def centralAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'central_admin', password: 'central_admin_password', tenant: '#(centralTenant)'}
    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def centralUser2 = { id: 'cd3f6cac-fa17-4079-9fae-2fb27e521412', username: 'central_user2', password: 'central_user2_password', tenant: '#(centralTenant)'}

    * def universityAdmin = { id: 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231', username: 'university_admin', password: 'university_admin_password', tenant: '#(universityTenant)'}
    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}
    * def universityUser2 = { id: '334e5a9e-94f9-4673-8d1d-ab552873886b', username: 'university_user2', password: 'university_user2_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = 'features/util/initData.feature@Login'

  Scenario: Create ['central', 'university'] tenants and set up admins
    * call read('features/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(centralAdmin)'}
    * call read('features/util/tenant-and-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityAdmin)'}

    # add 'consortia.all' permission to 'centralAdmin'
    * call read(login) centralAdmin
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

    # add 'consortia.all' permission to 'universityAdmin'
    * call read(login) universityAdmin
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all']}

  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: Destroy created ['university', 'central'] tenants
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}