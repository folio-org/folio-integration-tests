Feature: prepare dummy user for api test

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def randomUUID = uuid()
    * callonce read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

  Scenario: create dummy user
    * print "---create dummy user---"
    * def userName = "dummyUser" + randomUUID
    * def accessToken = karate.get('accessToken')
    Given path 'users-keycloak', 'users'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accessToken)'}
    And request
      """
    {
      "username": '#(userName)',
      "active":true,
      "departments": [],
      "proxyFor": [],
      "type": "patron",
      "personal": {"firstName":"Karate","lastName":'#("Dummy User " + userName)'}
    }
    """
    When method POST
    Then status 201
    * karate.set("dummyUserId", response.id)