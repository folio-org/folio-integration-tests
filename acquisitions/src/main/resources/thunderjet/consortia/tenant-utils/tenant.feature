Feature: Tenant object in mod-consortia api tests

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 15000 }

  @Positive
  Scenario: Create users with all different types to verify the case of skipping some types when enabling tenant
    # create user with shadow user
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA1",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d1",
      "departments": [],
      "type": "shadow"
    }
    """
    When method POST
    Then status 201

    # create user with dcb type
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA2",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d2",
      "departments": [],
      "type": "dcb"
    }
    """
    When method POST
    Then status 201

    # create user with patron type
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA3",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d3",
      "departments": [],
      "type": "patron"
    }
    """
    When method POST
    Then status 201

    # create user with system type
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": true,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA4",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d4",
      "departments": [],
      "type": "system"
    }
    """
    When method POST
    Then status 201

    # create user with staff type
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": false,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA5",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d5",
      "departments": [],
      "type": "staff"
    }
    """
    When method POST
    Then status 201

    # create user without type
    Given path 'users'
    And header x-okapi-tenant = collegeTenant
    And request
    """
    {
      "active": false,
      "personal": {
        "firstName": "firstname type testing 1",
        "preferredContactTypeId": "002",
        "lastName": "lastname type testing 1",
        "email": "AA@gamil.com"
      },
      "username": "AA6",
      "id": "e4686e5f-74bd-413a-b8d2-ee8ea01204d6",
      "departments": []
    }
    """
    When method POST
    Then status 201

  @Positive
  Scenario: Do POST a tenant, GET list of tenant(s) (isCentral = true), check value of 'setupStatus'
    # get tenants of the consortium (before posting any tenant)
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # post 'centralTenant' (isCentral = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true, isDeleted: false }

    # get tenant details for 'centralTenant'
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    When method GET
    Then status 200
    And match response.id == centralTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (after posting 'centralTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true, isDeleted:false }], totalRecords: 1 }

    # get tenant details for 'centralTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == centralTenant
    And match response.code == 'ABC'
    And match response.name == 'Central tenants name'
    And match response.isCentral == true
    And match response.isDeleted == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

  @Positive
  # This is for registering 'universityTenant'
  Scenario: Do POST a non-central tenant (isCentral = false), GET list of tenant(s), check value of 'setupStatus'
    # post 'universityTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false, isDeleted: false }

    # get tenant details for 'universityTenant'
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    When method GET
    Then status 200
    And match response.id == universityTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (should return 'centralTenant' and 'universityTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # get tenant details for 'universityTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == universityTenant
    And match response.code == 'XYZ'
    And match response.name == 'University tenants name'
    And match response.isCentral == false
    And match response.isDeleted == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'university_mod_users.user_tenant'
    * call login universityUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == universityTenant

  @Positive
  # This is for registering 'collegeTenant'
  Scenario: Do POST a non-central tenant (isCentral = false), GET list of tenant(s), check value of 'setupStatus'
    # post 'collegeTenant' (isCentral = false)
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(collegeTenant)', code: 'QWE', name: 'College tenants name', isCentral: false }
    When method POST
    Then status 201
    And match response == { id: '#(collegeTenant)', code: 'QWE', name: 'College tenants name', isCentral: false, isDeleted: false }

    # get tenant details for 'collegeTenant'
    Given path 'consortia', consortiumId, 'tenants', collegeTenant
    When method GET
    Then status 200
    And match response.id == collegeTenant
    Then assert response.setupStatus == 'IN_PROGRESS' || response.setupStatus == 'COMPLETED'

    # get tenants of the consortium (should return 'centralTenant' and 'universityTenant' and 'collegeTenant')
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response.totalRecords == 3

    # get tenant details for 'collegeTenant' and verify 'setupStatus' will become 'COMPLETED'
    Given path 'consortia', consortiumId, 'tenants', collegeTenant
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == collegeTenant
    And match response.code == 'QWE'
    And match response.name == 'College tenants name'
    And match response.isCentral == false
    And match response.isDeleted == false

    # verify there is a record for central tenant in 'central_mod_consortia.consortia_configuration'
    Given path 'consortia-configuration'
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.centralTenantId == centralTenant

    # verify 'dummy_user' has been saved in 'university_mod_users.user_tenant'
    * call login collegeUser1
    Given path 'user-tenants'
    And param query = 'username=dummy_user'
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].tenantId == collegeTenant

    # 4. Check that 'user-tenants' table in 'mod-users' of universityTenant.
    #    There must not be any record
    * call login universityUser1
    Given path 'user-tenants'
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
