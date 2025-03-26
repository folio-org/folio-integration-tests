Feature: login

  Background:
    * url baseUrl

  Scenario: search capabilities
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

    * def accesstoken = karate.get('accessToken')
    * def permissions = $userPermissions[*].name
    * def queryParam = function(field, values) { return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))' }

    Given path 'capabilities'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And param query = queryParam('permission', permissions)
    And param limit = permissions.length
    When method GET
    Then status 200
