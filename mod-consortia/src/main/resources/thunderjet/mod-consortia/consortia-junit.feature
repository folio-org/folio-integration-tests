# Please refer to the following document to see test cases for 'mod-consortia':
# https://wiki.folio.org/display/FOLIJET/Consortia+cases+covered+with+Karate+tests

Feature: mod-consortia integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table requiredModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'folio-custom-fields'       |
      | 'okapi'                     |

    # define consortium
    * def consortiumId = '111841e3-e6fb-4191-8fd8-5674a5107c32'

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random
    * def collegeTenant = 'college' + random

    # define main users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: 'cd3f6cac-fa17-4079-9fae-2fb28e521412', username: 'central_user1', password: 'central_user1_password', tenant: '#(centralTenant)'}
    * def centralUser2 = { id: 'cd3f6cac-fa17-4079-9fae-2fb27e521412', username: 'central_user2', password: 'central_user2_password', tenant: '#(centralTenant)'}

    * def universityUser1 = { id: '334e5a9e-94f9-4673-8d1d-ab552863886b', username: 'university_user1', password: 'university_user1_password', tenant: '#(universityTenant)'}
    * def universityUser2 = { id: '334e5a9e-94f9-4673-8d1d-ab552873886b', username: 'university_user2', password: 'university_user2_password', tenant: '#(universityTenant)'}

    * def collegeUser1 = { id: '9e21fe2c-8885-478a-95f9-bfada31dd912', username: 'college_user1', password: 'college_user1_password', tenant: '#(collegeTenant)'}
    * def collegeUser2 = { id: '2d928f81-ce02-4ad2-93f1-53246f8d3d72', username: 'college_user2', password: 'college_user2_password', tenant: '#(collegeTenant)'}

    # define custom login
    * def login = 'features/util/initData.feature@Login'

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call read('features/util/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('features/util/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}
    * call read('features/util/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', admin: '#(collegeUser1)'}

    # create users in all tenants
    * call read('features/util/create-users.feature@CreateUsers')

    # add 'consortia.all' (for consortia management) and 'tags.all' (for publish coordinator tests) permissions to main users
    * call read(login) consortiaAdmin
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

    * call read(login) universityUser1
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

    * call read(login) collegeUser1
    * call read('features/util/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

  Scenario: Consortium api tests
    * call read('features/consortium.feature')

  Scenario: Tenant api tests
    * call read('features/tenant.feature')

  Scenario: verify and setup 'consortiaAdmin' for all tenants
    * call read('features/consortia-admin-verification-and-setup.feature')

  Scenario: verify 'consortia-system-user' in all tenants
    * call read('features/consortia-system-users-verification.feature')

  Scenario: User-Tenant associations api tests
    * call read('features/user-tenant-associations.feature')

  Scenario: Publish coordinator tests
    * call read('features/publish-coordinator.feature')

  Scenario: Sharing Instances api tests
    * call read('features/sharing-instance.feature')

  Scenario: Sharing Settings api tests
    * call read('features/sharing-setting.feature')

  Scenario: Destroy created ['central', 'university', 'college'] tenants
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(collegeTenant)'}
    * call read('features/util/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
