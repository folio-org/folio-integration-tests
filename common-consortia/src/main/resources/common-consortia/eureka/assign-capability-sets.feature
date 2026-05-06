Feature: assign capability sets to a user

  Background:
    * url baseUrl

  Scenario: POST /users/capability-sets to assign the given capabilitySetIds to a user
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def sidecarToken = karate.get('okapitoken')
    Given path 'users', 'capability-sets'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(sidecarToken)' }
    And request { userId: '#(userId)', capabilitySetIds: '#(capabilitySetIds)' }
    When method POST
    # 201 = created, 422 = already assigned; both are acceptable
    Then match [201, 422] contains responseStatus
    * print 'DEBUG: assign capability sets result:', responseStatus, response
