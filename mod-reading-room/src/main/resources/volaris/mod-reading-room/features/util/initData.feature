Feature: init data for mod-reading-room

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    * def servicePointResponse = { "id": "#(servicePointId)", "name": "#(servicePointName)" }
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