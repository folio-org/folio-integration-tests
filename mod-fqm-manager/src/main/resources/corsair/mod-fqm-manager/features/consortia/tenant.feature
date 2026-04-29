Feature: Tenant object in mod-consortia

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure retry = { count: 20, interval: 15000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
  @Positive
  Scenario: Do POST a tenant, GET list of tenant(s) (isCentral = true)
    # get tenants of the consortium (before posting any tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # post a tenant with isCentral=true ('central' tenant)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'ABC', name: 'Consortium', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(centralTenant)', code: 'ABC', name: 'Consortium', isCentral: true, isDeleted: false }

    # get tenant details for 'central' tenant and wait for setup to complete
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == centralTenant
    And match response.code == 'ABC'
    And match response.name == 'Consortium'
    And match response.isCentral == true
    And match response.isDeleted == false

    # get tenants of the consortium (after posting 'central' tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(centralTenant)', code: 'ABC', name: 'Consortium', isCentral: true, isDeleted: false }], totalRecords: 1 }

    # verify that 'consortia_configuration' in 'central' tenant has record for 'central' tenant
    Given path 'consortia-configuration'
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    Given path 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { id:'ae62fbad-f2ee-4a68-9cd6-fbd639e43ad4', userId: '#(consortiaAdmin.id)', username:'dummy_user',tenantId :'#(centralTenant)', centralTenantId: '#(centralTenant)'}
    When method POST
    Then status 201

    * call login consortiaAdmin
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

  @Positive
  Scenario: Do POST a non-central tenant, GET list of tenant(s) (isCentral = false)
    # create 'university' tenant
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenant', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(universityTenant)', code: 'XYZ', name: 'University tenant', isCentral: false, isDeleted: false }

    # get tenant details for 'university' tenant and wait for setup to complete
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == universityTenant
    And match response.code == 'XYZ'
    And match response.name == 'University tenant'
    And match response.isCentral == false
    And match response.isDeleted == false

    # get tenants by consortiumId - should get two tenants
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # verify that 'consortia_configuration' in 'university' tenant has record for 'central' tenant
    Given path 'consortia-configuration'
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'user_tenant' table in 'university_mod_users'
    * call login universityUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant

    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') { tenant: '#(universityTenant)', user: '#(consortiaAdmin)', userPermissions: '#(userPermissions)' }

  @Positive
  Scenario: Do POST a second non-central tenant, GET list of tenant(s) (isCentral = false)
    # create 'college' tenant
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(collegeTenant)', code: 'QWE', name: 'College tenant', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(collegeTenant)', code: 'QWE', name: 'College tenant', isCentral: false, isDeleted: false }

    # get tenant details for 'college' tenant and wait for setup to complete
    Given path 'consortia', consortiumId, 'tenants', collegeTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == collegeTenant
    And match response.code == 'QWE'
    And match response.name == 'College tenant'
    And match response.isCentral == false
    And match response.isDeleted == false

    # get tenants by consortiumId - should get three tenants
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 3

    # verify that 'consortia_configuration' in 'college' tenant has record for 'central' tenant
    Given path 'consortia-configuration'
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'user_tenant' table in 'college_mod_users'
    * call login collegeUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == collegeTenant

    * call read('classpath:common-consortia/eureka/initData.feature@PutCaps') { tenant: '#(collegeTenant)', user: '#(consortiaAdmin)', userPermissions: '#(userPermissions)' }
