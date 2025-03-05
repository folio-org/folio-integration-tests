Feature: Tenant object in mod-consortia api tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }

  @Positive
  Scenario: Do POST a tenant, GET list of tenant(s) (isCentral = true), check value of 'setupStatus'
    # get tenants of the consortium (before posting any tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # post 'centralTenant' (isCentral = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(tenant.id)', code: 'ABC', name: 'Central tenants name', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(tenant.id)', code: 'ABC', name: 'Central tenants name', isCentral: true, isDeleted: false }

    # get tenant details for 'centralTenant'
    Given path 'consortia', consortiumId, 'tenants', tenant.id
    When method GET
    Then status 200
    And match response.id == tenant.id
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (after posting 'centralTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(tenant.id)', code: 'ABC', name: 'Central tenants name', isCentral: true, isDeleted:false }], totalRecords: 1 }

    # get tenant details for 'centralTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', tenant.id
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == tenant.id
    And match response.code == 'ABC'
    And match response.name == 'Central tenants name'
    And match response.isCentral == true
    And match response.isDeleted == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    When method GET
    Then status 200
    And match response.centralTenantId == tenant.id

  @Positive
  # This is for registering 'universityTenant'
  Scenario: Do POST a non-central tenant (isCentral = false), GET list of tenant(s), check value of 'setupStatus'
    # post 'universityTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(uniTenant.id)', code: 'XYZ', name: 'University tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(uniTenant.id)', code: 'XYZ', name: 'University tenants name', isCentral: false, isDeleted: false }

    # get tenant details for 'universityTenant'
    Given path 'consortia', consortiumId, 'tenants', uniTenant.id
    When method GET
    Then status 200
    And match response.id == uniTenant.id
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (should return 'centralTenant' and 'universityTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # get tenant details for 'universityTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', uniTenant.id
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == uniTenant.id
    And match response.code == 'XYZ'
    And match response.name == 'University tenants name'
    And match response.isCentral == false
    And match response.isDeleted == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    And header x-okapi-tenant = uniTenant.id.name
    When method GET
    Then status 200
    And match response.centralTenantId == tenant.id

    # verify 'dummy_user' has been saved in 'university_mod_users.user_tenant'
    * call login universityUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(uniTenant.id.name)', 'x-okapi-token':'#(token)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == uniTenant.id