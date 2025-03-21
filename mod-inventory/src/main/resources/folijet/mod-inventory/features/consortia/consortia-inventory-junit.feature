Feature: mod-inventory ECS tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * call login admin
    * def samplesPath = 'classpath:folijet/mod-inventory/samples/'

    * table requiredModules
      | name                        |
      | 'okapi'                     |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-inventory'             |
      | 'mod-permissions'           |
      | 'mod-inventory-storage'     |
      | 'mod-pubsub'                |
      | 'mod-circulation-storage'   |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |
      | 'folio-custom-fields'       |

    # define custom login
    * def login = read('classpath:common-consortia/initData.feature@Login')

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', admin: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', admin: '#(universityUser1)'}
    * call read('classpath:common-consortia/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', admin: '#(collegeUser1)'}

    # Temporary fix, should be removed after implementing proper consortium data cache handling during install operation at mod-inventory-storage
    * call pause 360000

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

  Scenario: Add affilitions
    * call login consortiaAdmin
    * call read('classpath:common-consortia/affiliation.feature@AddAffiliation') { user: '#(universityUser1)', tenant: '#(collegeTenant)' }

    # add non-empty permission to shadow 'centralUser1'
    * call read('classpath:common-consortia/initData.feature@PutPermissions') { id: '#(universityUser1.id)', tenant: '#(collegeTenant)', desiredPermissions: ['consortia.all']}

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

  Scenario: Create college custom location
    * call login collegeUser1

    * configure headers = { 'x-okapi-tenant':'#(collegeTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    Given path 'locations'
    And request read(samplesPath + 'locations-consortiaonline.json')
    When method POST
    Then status 201

  Scenario: create holdings source type
    * def holdingsSource = read('classpath:folijet/mod-inventory/samples/holdings_source.json')

    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * call read('classpath:folijet/mod-inventory/features/utils.feature@PostHoldingsSource') {holdingsSource: #(holdingsSource)}

    * call login universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * call read('classpath:folijet/mod-inventory/features/utils.feature@PostHoldingsSource') {holdingsSource: #(holdingsSource)}

    * call login collegeUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * call read('classpath:folijet/mod-inventory/features/utils.feature@PostHoldingsSource') {holdingsSource: #(holdingsSource)}