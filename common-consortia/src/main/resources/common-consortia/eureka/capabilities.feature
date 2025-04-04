Feature: capability

  Background:
    * url baseUrl

  Scenario: search capabilities
    * configure headers = null
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

    * def token = karate.get('accessToken')
    * def permissions = $userPermissions[*].name
    * def queryParam = function(field, values) { return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))' }

    Given path 'capabilities'
    And headers {'x-okapi-tenant':'#(tenantName)', 'x-okapi-token': '#(token)'}
    And param query = queryParam('permission', permissions)
    And param limit = permissions.length
    When method GET
    Then status 200
