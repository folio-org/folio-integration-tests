Feature: capability

  Background:
    * url baseUrl
    * def anyMatchByFieldQuery =
    """
      function(field, values) {
        return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))'
    }
    """

  @getCapabilities
  Scenario: search capabilities
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

    * def accesstoken = karate.get('accessToken')
    * def permissions = $userPermissions[*].name

    Given path 'capabilities'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And param query = anyMatchByFieldQuery('permission', permissions)
    And param limit = permissions.length
    When method GET
    Then status 200

  @getCapabilitySets
  Scenario: search capability sets
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')

    * def accesstoken = karate.get('accessToken')
    * def permissions = $userPermissions[*].name

    Given path 'capability-sets'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And param query = anyMatchByFieldQuery('permission', permissions)
    And param limit = permissions.length
    When method GET
    Then status 200

    * print "---Let's check capabilities---"
    * eval karate.sleep(600000)

