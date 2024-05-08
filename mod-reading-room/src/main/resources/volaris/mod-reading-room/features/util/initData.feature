Feature: init data for mod-reading-room

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def util1 = call read('classpath:common/util/uuid1.feature')
    * def util2 = call read('classpath:common/util/random_string.feature')
    * def patronId = util1.uuid1()
    * def patronName = util2.random_string()


  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PostReadingRoom
  Scenario: create reading room
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

  @PostPatronGroupAndUser
  Scenario: create PatronGroup & User
    * def createPatronGroupRequest = read('samples/PatronGroup/create-patronGroup-request.json')

    Given path 'groups'
    And request createPatronGroupRequest
    When method POST
    Then status 201

    * def patronGroupId = response.id
    * def createUserRequest = read('samples/User/create-user-request.json')

    Given path 'users'
    And request createUserRequest
    When method POST
    Then status 201