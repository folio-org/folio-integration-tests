Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-consortia'             |

    * table userPermissions
      | name                                   |
      | 'consortia.all'                        |

    # consortia
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'

    # test tenants' names creation
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random

    # test users setup
    * def centralAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'central_admin', password: 'central_admin_password', tenant: '#(centralTenant)'}
    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def centralUser2 = { id: 'cd3f6cac-fa17-4079-9fae-2fb27e521412', username: 'central_user2', password: 'central_user2_password', tenant: '#(centralTenant)'}

    * def universityAdmin = { id: 'd9cd0bed-1b49-4b5e-a7bd-064b8d177231', username: 'university_admin', password: 'university_admin_password', tenant: '#(universityTenant)'}
    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}
    * def universityUser2 = { id: '334e5a9e-94f9-4673-8d1d-ab552873886b', username: 'university_user2', password: 'university_user2_password', tenant: '#(universityTenant)'}

    # define custom login
    * def login = 'features/util/initData.feature@Login'

  Scenario: Create 'central' tenant and set up users
    # create tenant
    * call read('features/util/initData.feature@PostTenant') { id: '#(centralTenant)', name: 'Central tenant', description: 'Tenant named central for mod-consortia testing'}
    # install required module(s)
    * call read('features/util/initData.feature@InstallModules') { modules: '#(modules)', tenant: '#(centralTenant)'}
    # set up 'admin-user' with all permission(s) - 'mod-auth' is not enabled
    * call read('features/util/initData.feature@SetUpUser') centralAdmin
    * call read('features/util/initData.feature@AddAdminPermissions') centralAdmin
    # set up 'test-user' with specified permission(s) - 'mod-auth' is not enabled
    * call read('features/util/initData.feature@SetUpUser') centralUser1
    * call read('features/util/initData.feature@AddUserPermissions') centralUser1
    # enable 'mod-authtoken' for 'central' tenant
    * call read('features/util/initData.feature@InstallModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(centralTenant)'}

  Scenario: Create 'university' tenant and set up user(s)
    # create tenant
    * call read('features/util/initData.feature@PostTenant') { id: '#(universityTenant)', name: 'University tenant', description: 'Tenant named university for mod-consortia testing'}
    # install required module(s)
    * call read('features/util/initData.feature@InstallModules') { modules: '#(modules)', tenant: '#(universityTenant)'}
    # set up 'admin-user' with all permission(s) - 'mod-auth' is not enabled
    * call read('features/util/initData.feature@SetUpUser') universityAdmin
    * call read('features/util/initData.feature@AddAdminPermissions') universityAdmin
    # enable 'mod-authtoken' for 'university' tenant
    * call read('features/util/initData.feature@InstallModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(universityTenant)'}

  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: Destroy created ['university', 'central'] tenant(s)
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}