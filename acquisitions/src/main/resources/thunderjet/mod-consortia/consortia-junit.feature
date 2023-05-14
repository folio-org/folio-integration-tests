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
    * def universityTenant = 'university' + random
    * def collegeTenant = 'college' + random

    # test users setup
    * def universityAdmin = read('features/samples/custom-users.json')[0]
    * def universityUser = read('features/samples/custom-users.json')[1]

    * def collegeAdmin = read('features/samples/custom-users.json')[2]
    * def collegeUser = read('features/samples/custom-users.json')[3]

  Scenario: Create 'university' tenant and set up users
    # create tenant
    * call read('features/util/initData.feature@PostTenant') { id: '#(universityTenant)', name: 'University tenant', description: 'Tenant named university for mod-consortia testing'}
    # install required module(s)
    * call read('features/util/initData.feature@InstallModules') { modules: '#(modules)', tenant: '#(universityTenant)'}
    # set up 'admin-user' with all permission(s)
    * call read('features/util/initData.feature@PostUserWithCredentials') universityAdmin
    * call read('features/util/initData.feature@AddAdminPermissions') universityAdmin
    # set up 'test-user' with specified permission(s)
    * call read('features/util/initData.feature@PostUserWithCredentials') universityUser
    * call read('features/util/initData.feature@AddUserPermissions') universityUser
    # enable 'mod-authtoken'
    * call read('features/util/initData.feature@InstallModules') { modules: [{name: 'mod-authtoken'}], tenant: '#(universityTenant)'}

  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: Destroy 'university' tenant
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}