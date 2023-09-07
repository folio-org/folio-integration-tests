Feature: Consortia Skip not required user types api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Authtoken-Refresh-Cache': 'true', 'Accept': 'application/json' }
    * configure retry = { count: 10, interval: 1000 }

  Scenario: Create a user called 'shadowUser' in 'universityTenant' and verify that this user not processed by consortia pipeline:
    # create new user called 'shadowUser' with type = 'shadow' in 'universityTenant'
    * call read('features/util/initData.feature@PostUser') shadowUser

    # 1. verify there is no record in 'user_tenant' table in 'central_mod_users' for 'shadowUser'
    * def queryParams = { userId: '#(shadowUser.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    # 2. verify there is no record in 'user_tenant' table in 'central_mod_consortia' for 'shadowUser'
    * def queryParams = { userId: '#(shadowUser.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET
    And match response.errors[0].message == 'Object with userId [' + shadowUser.id +'] was not found'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'NOT_FOUND_ERROR'

  Scenario: Create a user called 'patronUser' in 'collegeTenant' and verify that this user not processed by consortia pipeline:
    # create new user called 'patronUser' with type = 'patron' in 'collegeTenant'
    * call read('features/util/initData.feature@PostUser') patronUser

    # 1. verify there is no record in 'user_tenant' table in 'central_mod_users' for 'patronUser'
    * def queryParams = { userId: '#(patronUser.id)' }
    Given path 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    # 2. verify there is no record in 'user_tenant' table in 'central_mod_consortia' for 'patronUser'
    * def queryParams = { userId: '#(patronUser.id)' }
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = queryParams
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until responseStatus == 404
    When method GET
    And match response.errors[0].message == 'Object with userId [' + patronUser.id +'] was not found'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'NOT_FOUND_ERROR'
