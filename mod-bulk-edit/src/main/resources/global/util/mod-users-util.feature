Feature: setup user data feature

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
#    * configure retry = { interval: 3000, count: 10 }

  @PostUser
  Scenario: POST user
    Given path 'users'
    And request user
    When method POST
    Then status 201

  @PutUser
  Scenario: UPDATE user
    Given path 'users', userId
    And request user
    When method PUT
    Then status 204

  @PostAddressType
  Scenario: POST addresstype
    Given path 'addresstypes'
    And request addressType
    When method POST
    Then status 201

  @PostDepartment
  Scenario: POST department
    Given path 'departments'
    And request department
    When method POST
    Then status 201

  @PostPatronGroup
  Scenario: POST patron group
    Given path 'groups'
    And request group
    When method POST
    Then status 201

  @PostProxiesFor
  Scenario: POST patron group
    Given path 'proxiesfor'
    And request proxyFor
    When method POST
    Then status 201