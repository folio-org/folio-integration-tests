Feature: find capability set IDs by permission name

  Background:
    * url baseUrl

  Scenario: GET /capability-sets?query=permissions==<permission> and return matching IDs
    # Called with: { tenant, okapitoken, permission }
    Given path 'capability-sets'
    And param query = '(permissions=="' + permission + '")'
    And param limit = 20
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    When method GET
    Then match [200, 404] contains responseStatus
    * def ids = (responseStatus == 200 && response.capabilitySets && response.capabilitySets.length > 0) ? response.capabilitySets.map(function(x){ return x.id }) : []
    * print 'DEBUG: find-capability-sets-by-permission result for', permission, ':', ids

