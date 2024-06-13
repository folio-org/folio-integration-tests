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
      | 'okapi'                     |

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