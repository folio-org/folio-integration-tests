Feature:

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @PostGroupAndUser
  Scenario: Create a group and a user
    * def group = read('samples/group-entity.json')
    * def user = read('samples/user-entity.json')
    * group.patronGroupId = patronGroupId
    * user.id = userId
    * user.barcode = userBarcode

    Given path 'groups'
    And request group
    When method POST
    Then status 201

    Given path 'users'
    And request user
    When method POST
    Then status 201

  @PostGroup
  Scenario: create group
    * def group = read('samples/group-entity.json')
    * group.patronGroupId = patronGroupId

    Given path 'groups'
    And request group
    When method POST
    Then status 201

  @PostUser
  Scenario: create user
    * def user = read('samples/user-entity.json')

    Given path 'users'
    And request user
    When method POST
    Then status 201