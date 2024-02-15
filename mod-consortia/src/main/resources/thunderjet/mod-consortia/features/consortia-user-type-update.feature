Feature: Consortia User type Update tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 2000 }

  Scenario: Update 'patronUserToUpdate' user type from 'patron' to 'staff' and primary affiliation should appear
    # 1. create new user called 'patronUserToUpdate' with type = 'patron' in 'collegeTenant'
    * call read('features/util/initData.feature@PostUser') patronUserToUpdate

    # 2. update user called 'patronUserToUpdate' with type 'staff'
    Given path 'users', patronUserToUpdate.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy staffUserCopy = response
    * set staffUserCopy.type = 'staff'

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain' }
    Given path 'users', staffUserCopy.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request staffUserCopy
    When method PUT
    Then status 204
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    # 3. verify that primary affiliation was created for 'patronUserToUpdate'
    * def queryParams = { username: '#(patronUserToUpdate.username)', tenantId: '#(collegeTenant)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.userTenants[0].userId == patronUserToUpdate.id
    And match response.userTenants[0].isPrimary == true
    And match response.userTenants[0].username == patronUserToUpdate.username

    # 4. verify that all fields updated in mod-users /user-tenant central tenant
    * def queryParams = { username: '#(patronUserToUpdate.username)', userId: '#(patronUserToUpdate.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.userTenants[0].tenantId == collegeTenant
    And match response.userTenants[0].centralTenantId == centralTenant
    And match response.userTenants[0].consortiumId == consortiumId
    And match response.userTenants[0].username == patronUserToUpdate.username
    And match response.userTenants[0].userId == patronUserToUpdate.id

    # 5. update user type to patron again
    Given path 'users', patronUserToUpdate.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200
    * copy patronUserCopy = response
    * set patronUserCopy.type = 'patron'

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/plain' }
    Given path 'users', patronUserCopy.id
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request patronUserCopy
    When method PUT
    Then status 204
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    # 6. verify there is no record in 'user_tenant' table in 'central_mod_consortia' for 'patronUserToUpdate'
    * def queryParams = { userId: '#(patronUserToUpdate.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET
    And match response.errors[0].message == 'Object with userId [' + patronUserToUpdate.id +'] was not found'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'NOT_FOUND_ERROR'

    # 7. verify there is no record in 'user_tenant' table in 'central_mod_users' for 'patronUserToUpdate'
    * def queryParams = { userId: '#(patronUserToUpdate.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 0
    When method GET
    Then status 200


  @Positive
  Scenario: Verify that two system users can be created in different tenant
    # 1.1 Create two system user with username 'user1'
    Given path 'users'
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      "id":"1efc2b3e-76de-41dc-a3c3-a5ef90e33483",
      "username": 'user1',
      "active":true,
      "personal": {"firstName":"User 1","lastName":'User 1'},
      "type": "system"
    }
    """
    When method POST
    Then status 201

    * call pause 1000

    # 1.2 Create second user with same username, Operation must be allowed
    Given path 'users'
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      "id":"b5fc7128-b783-4820-9a6b-3d4b35ebeff9",
      "username": 'user1',
      "active": true,
      "personal": {"firstName":"User 1","lastName":'User 1'},
      "type": "system"
    }
    """
    When method POST
    Then status 201

    # 2.1 Creating 'staff' user type with 'user2'
    Given path 'users'
    And headers {'x-okapi-tenant':'#(universityTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      "id": "f6188537-b538-431d-90cd-6c0a34fce0a8",
      "username": 'user2',
      "active": true,
      "personal": {"firstName":"User 2","lastName":'User 2'},
      "type": "staff"
    }
    """
    When method POST
    Then status 201

    # 2.1.1 Check that user 'user2' is appeared in user-tenant table
    * def queryParams = { username: 'user2', userId: 'f6188537-b538-431d-90cd-6c0a34fce0a8' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # 2.2 Creating second user with same username, Operation must be forbidden because of validation
    Given path 'users'
    And headers {'x-okapi-tenant':'#(collegeTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request
    """
    {
      "id":"9f2d1515-a5cf-445b-866a-52913352d0a6",
      "username": 'user2',
      "active": true,
      "personal": {"firstName":"User 2","lastName":"User 2"},
      "type": "staff"
    }
    """
    When method POST
    Then status 422
    And match response ==  {"errors":[{"message":"User with this username already exists","type":"1","code":"-1","parameters":[{"key":"username","value":"user2"}]}]}