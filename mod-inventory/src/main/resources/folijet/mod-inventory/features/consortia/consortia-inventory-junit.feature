@Ignore
Feature: mod-inventory ECS tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * call login admin

    * table requiredModules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'folio-custom-fields'       |
      | 'okapi'                     |

    # generate names for tenants
    * def random = callonce randomMillis
    * def centralTenant = 'central' + random
    * def universityTenant = 'university' + random
    * def collegeTenant = 'college' + random

    * def centralUser1Id = callonce uuid
    * def userPhone = '11111-11111'
    * def userMobilePhone = '00000-11111'

    * def universityUser1Id = callonce uuid
    * def universityUser1Phone = '22222-22222'
    * def universityUser1MobilePhone = '00000-22222'

    * def collegeUser1Id = callonce uuid

    # define consortium
    * def consortiumId = callonce uuid

    # define main users
    * def consortiaAdmin = { id: '122b3d2b-4788-4f1e-9117-56daa91cb75c', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)'}

    * def centralUser1 = { id: '#(centralUser1Id)', username: 'central_user1', password: 'central_user1_password', type: 'staff', tenant: '#(centralTenant)', phone: '#(userPhone)', mobilePhone: '#(userMobilePhone)'}
    * def universityUser1 = { id: '#(universityUser1Id)', username: 'university_user1', password: 'university_user1_password', type: 'staff', tenant: '#(universityTenant)', phone: '#(universityUser1Phone)', mobilePhone:  '#(universityUser1MobilePhone)'}
    * def collegeUser1 = { id: '#(collegeUser1Id)', username: 'college_user1', password: 'college_user1_password', type: 'staff', tenant: '#(collegeTenant)'}

    # define custom login
    * def login = read('classpath:common-consortia/initData.feature@Login')

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', admin: '#(collegeUser1)'}

    # add 'consortia.all' (for consortia management) and 'tags.all' (for publish coordinator tests) permissions to main users
    * call login consortiaAdmin
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

    * call login universityUser1
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all', 'consortia.sharing-instances.item.post']}

    * call login collegeUser1
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { desiredPermissions: ['consortia.all', 'tags.all']}

  Scenario: Create consortium and setup tenants
    * call login consortiaAdmin
    * call read('classpath:common-consortia/consortium.feature@SetupConsortia')

    * call read('classpath:common-consortia/consortium.feature@SetupTenantForConsortia') { tenant: '#(centralTenant)', isCentral: true, code: 'ABC' }
    * call read('classpath:common-consortia/consortium.feature@SetupTenantForConsortia') { tenant: '#(universityTenant)', isCentral: false, code: 'XYZ' }
    * call read('classpath:common-consortia/consortium.feature@SetupTenantForConsortia') { tenant: '#(collegeTenant)', isCentral: false, code: 'BEE' }

  Scenario: Update hrId for all tenants
    * call login consortiaAdmin
    * call read('classpath:folijet/mod-inventory/features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(centralTenant)', prefix: 'cons' }

    * call login universityUser1
    * call read('classpath:folijet/mod-inventory/features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(universityTenant)', prefix: 'u' }

    * call login collegeUser1
    * call read('classpath:folijet/mod-inventory/features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(collegeTenant)', prefix: 'o' }

  Scenario: Сreate locations
    Given call read('classpath:folijet/mod-inventory/features/locations.feature') { testUser : '#(consortiaAdmin)' }
    Given call read('classpath:folijet/mod-inventory/features/locations.feature') { testUser : '#(universityUser1)' }
    Given call read('classpath:folijet/mod-inventory/features/locations.feature') { testUser : '#(collegeUser1)' }

  Scenario: Update ownership api tests
    * call read('features/update-ownership.feature')

  Scenario: Destroy created ['central', 'university', 'college'] tenants
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(universityTenant)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(collegeTenant)'}
    * call read('classpath:common-consortia/initData.feature@DeleteTenant') { tenant: '#(centralTenant)'}
