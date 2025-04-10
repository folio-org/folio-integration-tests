Feature: capability

  Background:
    * url baseUrl

  Scenario: search capabilities
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')

    * def okapitoken = karate.get('okapitoken')
    * def permissions = $userPermissions[*].name
    * def queryParam = function(field, values) { return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))' }

    Given path 'capabilities'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token': '#(okapitoken)'}
    And param query = queryParam('permission', permissions)
    And param limit = permissions.length
    When method GET
    Then status 200
