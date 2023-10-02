Feature: Consortia User type Update tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }

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