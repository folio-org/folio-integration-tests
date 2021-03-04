Feature: setup test users

  Background:
    * url baseUrl
    * configure readTimeout = 190000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }

  Scenario: create test users
    Given path 'users'
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "id": #(testUser.id),
      "username": '#(testUser.name)',
      "active":true,
      "personal": {"firstName":"oai","lastName":"pmh"}
    }
    """
    When method POST
    Then status 201

  Scenario: specify user credentials
    Given path 'authn/credentials'
    And header x-okapi-tenant = testUser.tenant
    And request {username: '#(testUser.name)', password :'#(testUser.password)'}
    When method POST
    Then status 201

  Scenario: get permissions for admin and add to new test user
    Given path '/perms/permissions'
    And header x-okapi-tenant = testUser.tenant
    And param length = 1000
    And param query = '(subPermissions="" NOT subPermissions ==/respectAccents []) and (cql.allRecords=1 NOT childOf <>/respectAccents [])'
    When method GET
    Then status 200
    * def permissions = $.permissions[*].permissionName

  Scenario: add permissions for test user
    * def permissions = $userPermissions[*].name
    Given path 'perms/users'
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "userId": #(testUser.id),
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: enable mod-authtoken module
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testUser.tenant)'}