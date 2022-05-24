Feature: setup user data feature

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }

  @PostInstance
  Scenario: POST inventory
    Given path 'inventory'
    Given path 'instances'
    And request instance
    When method POST
    Then status 201

  @PostHoldings
  Scenario: POST holdings
    Given path 'holdings-storage'
    Given path 'holdings'
    And request holdings
    When method POST
    Then status 201

  @PostItems
  Scenario: POST Items
    Given path 'inventory'
    Given path 'items'
    And request item
    When method POST
    Then status 201

#  @PutUser
#  Scenario: UPDATE user
#    Given path 'users', userId
#    And request user
#    When method PUT
#    Then status 204
#
#  @PostAddressType
#  Scenario: POST addresstype
#    Given path 'addresstypes'
#    And request addressType
#    When method POST
#    Then status 201
#
#  @PostDepartment
#  Scenario: POST department
#    Given path 'departments'
#    And request department
#    When method POST
#    Then status 201
#
#  @PostPatronGroup
#  Scenario: POST patron group
#    Given path 'groups'
#    And request group
#    When method POST
#    Then status 201
#
#  @PostProxiesFor
#  Scenario: POST patron group
#    Given path 'proxiesfor'
#    And request proxyFor
#    When method POST
#    Then status 201