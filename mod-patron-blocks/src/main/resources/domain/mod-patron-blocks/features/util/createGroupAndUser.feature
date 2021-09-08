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
    * user.username = random_string()
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
    * group.group = random_string()
    Given path 'groups'
    And request group
    When method POST
    Then status 201

  @PostUserWithKnownIdAndBarcode
  Scenario: create user with id and barcode
    * def user = read('samples/user-entity.json')
    Given path 'users'
    And request user
    When method POST
    Then status 201

  @PostUser
  Scenario: create user
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def username = random_string()
    * def user = read('samples/user-entity.json')
    Given path 'users'
    And request user
    When method POST
    Then status 201