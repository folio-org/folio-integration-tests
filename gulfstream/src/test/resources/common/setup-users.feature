Feature: prepare data for api test

  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login admin

  Scenario: create new tenant
    Given call read('classpath:common/tenant.feature@create') { tenant: '#(testUser.tenant)'}

  Scenario: get and install configured modules
    Given call read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}

  Scenario: create test users
    Given path 'users'
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "id":"00000000-1111-5555-9999-999999999991",
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
    * def additional = $adminAdditionalPermissions[*].name
    * def permissions = karate.append(permissions, additional)

    # add permissions to admin user
    Given path 'perms/users'
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999991",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: add permissions for test user
    * def permissions = $userPermissions[*].name
    Given path 'perms/users'
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "userId":"00000000-1111-5555-9999-999999999992",
      "permissions": #(permissions)
    }
    """
    When method POST
    Then status 201

  Scenario: enable mod-authtoken module
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-authtoken'}], tenant: '#(testUser.tenant)'}

  Scenario: login users
    * call login admin
    * karate.properties['adminToken'] = responseHeaders['x-okapi-token'][0]

    * call login testUser
    * karate.properties['testUserToken'] = responseHeaders['x-okapi-token'][0]