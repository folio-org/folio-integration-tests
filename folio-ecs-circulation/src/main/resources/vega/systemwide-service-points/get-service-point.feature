Feature: Helper - get service-point by id from a given tenant

  @GetServicePoint
  Scenario: login and query service-points
    * url baseUrl
    * configure cookies = null
    * configure headers = null

    # login
    Given path 'authn/login'
    And header x-okapi-tenant = tenant
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 201
    * def token = response.okapiToken

    # query
    Given url baseUrl
    And path 'service-points'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = token
    And header x-okapi-tenant = tenant
    And param query = 'id=="' + servicePointId + '"'
    When method GET
    Then status 200
    * def totalRecords = response.totalRecords
    * def servicepoints = response.servicepoints

