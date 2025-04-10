Feature: mod-inventory ECS tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin
    * def samplesPath = 'classpath:folijet/mod-inventory/samples/'

    * table modules
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

    * table userPermissions
      | name                                                      |
      | 'inventory-storage.hrid-settings.item.put'                |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.holdings-sources.item.post'            |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory.items.item.post'                               |
      | 'inventory.instances.item.get'                            |
      | 'inventory.holdings.update-ownership.item.post'           |
      | 'inventory-storage.holdings.collection.get'               |
      | 'inventory.items-by-holdings-id.collection.get'           |
      | 'inventory.instances.item.post'                           |
      | 'inventory-storage.bound-withs.collection.put'            |
      | 'inventory.items.item.put'                                |



    # define custom login
    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: Create ['central', 'university', 'college'] tenants and set up admins
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)'}
    * call read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant') { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)'}

  Scenario: Create consortium and setup tenants
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia') { tenant: '#(centralTenant)' }

    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'ABC' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'XYZ' }
    * call read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia') { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'BEE' }

  Scenario: Add affilitions
    * call login consortiaAdmin
    * call read('classpath:common-consortia/eureka/affiliation.feature@AddAffiliation') { user: '#(universityUser1)', tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)'  }

    * table notEmptyPermissinos
      | name            |
      | 'consortia.all' |
    # add non-empty permission to shadow 'centralUser1'
    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') { id: '#(universityUser1.id)', tenant: '#(collegeTenant)', userPermissions: '#(notEmptyPermissinos)'}

  Scenario: Update hrId for all tenants
    * call login consortiaAdmin
    * call read('classpath:folijet/mod-inventory/eureka-features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(centralTenant)', prefix: 'cons' }

    * call login universityUser1
    * call read('classpath:folijet/mod-inventory/eureka-features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(universityTenant)', prefix: 'u' }

    * call login collegeUser1
    * call read('classpath:folijet/mod-inventory/eureka-features/consortia/util/hrid-util.feature@UpdateHrId') { tenant: '#(collegeTenant)', prefix: 'o' }

  Scenario: Сreate locations
    Given call read('classpath:folijet/mod-inventory/eureka-features/locations.feature') { testUser : '#(consortiaAdmin)' }
    Given call read('classpath:folijet/mod-inventory/eureka-features/locations.feature') { testUser : '#(universityUser1)' }
    Given call read('classpath:folijet/mod-inventory/eureka-features/locations.feature') { testUser : '#(collegeUser1)' }

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
    * call read('classpath:folijet/mod-inventory/eureka-features/utils.feature@PostHoldingsSource') {testTenant: '#(centralTenant)', holdingsSource: '#(holdingsSource)'}

    * call login universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * call read('classpath:folijet/mod-inventory/eureka-features/utils.feature@PostHoldingsSource') {testTenant: '#(universityTenant)', holdingsSource: '#(holdingsSource)'}

    * call login collegeUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }
    * call read('classpath:folijet/mod-inventory/eureka-features/utils.feature@PostHoldingsSource') {testTenant: '#(collegeTenant)', holdingsSource: '#(holdingsSource)'}