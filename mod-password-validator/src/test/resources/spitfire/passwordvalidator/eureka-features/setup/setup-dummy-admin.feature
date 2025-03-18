Feature: prepare dummy admin for api test

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def adminId = "00000000-1111-5555-9999-999999999991"
    * def adminUserName = testAdmin.name
    * def adminPassword = testAdmin.password
    * callonce read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

  Scenario: create dummy admin
    * print "---create dummy user---"
    * def accessToken = karate.get('accessToken')
    Given path 'users-keycloak', 'users'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accessToken)'}
    And request
      """
    {
      "username": '#(adminUserName)',
      "id": "#(adminId)",
      "active":true,
      "departments": [],
      "proxyFor": [],
      "type": "patron",
      "personal": {"firstName":"Karate","lastName":'#("User" + adminUserName)'}
    }
    """
    When method POST
    Then status 201
