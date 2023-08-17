Feature: Tenant object in mod-consortia

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
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
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }

    # get tenants of the consortium (after posting 'central' tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }], totalRecords: 1 }

    # verify that 'consortia_configuration' in 'central' tenant has record for 'central' tenant
    Given path 'consortia-configuration'
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

  @Positive
  Scenario: Do POST a non-central tenant, GET list of tenant(s) (isCentral = false)
    # create 'university' tenant
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }

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
    * call read(login) universityUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant