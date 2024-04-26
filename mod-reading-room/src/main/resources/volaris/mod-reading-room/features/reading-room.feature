Feature: ReadingRoom tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * def readingRoomId = '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    * def readingRoomName = 'reading-room-1'
    * def servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'
    * def servicePointName = 'test service point'
    * def servicePointCode = 'test'

  Scenario: Create a new reading room
    * print "Create a new reading room"
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')

  Scenario: Create a reading room which is already exist
    * print "reading room already exist"
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 409

  Scenario: Create a reading room where service point is not found
    * print "Create a reading room where service point is not found"
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-1_f'
    * def servicePointId = call uuid1
    * def servicePointName = 'not existing service point'
    * def servicePointCode = 'not exist'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 422

  Scenario: Create a reading room where service point is already associated to other reading room
    * print "Create a reading room where service point is already associated to other reading room"
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-2_f'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 422

    Scenario: Update a reading room
      * print "Update a reading room"
      * def updatedName = 'reading-room-1-updated'
      Given path 'reading-room/' + readingRoomId
      And request
        """
        {
          "id": "#(readingRoomId)",
          "name": "#(updatedName)",
          "isPublic": "true",
          "servicePoints":[
            {
              "value": "#(servicePointId)",
              "label": "#(servicePointName)",
            },
          ] ,
        }
        """
      When method PUT
      Then status 200
      And match response.name == "#(updatedName)"

    Scenario: Update a reading room with id miss match
      * print "Update a reading room with id miss match"
      * def differentId = call uuid1
      Given path 'reading-room/' + differentId
      And request
        """
        {
          "id": "#(readingRoomId)",
          "name": "#(updatedName)",
          "isPublic": "true",
          "servicePoints":[
            {
              "value": "#(servicePointId)",
              "label": "#(servicePointName)",
            },
          ] ,
        }
        """
      When method PUT
      Then status 422

    Scenario: Update a reading room when reading room not exist
      * print "Update a reading room when reading room not exist"
      * def updatedName = 'reading-room-1-updated'
      * def notExistingReadingRoomId = call uuid1
      Given path 'reading-room/' + notExistingReadingRoomId
      And request
        """
        {
          "id": "#(notExistingReadingRoomId)",
          "name": "#(updatedName)",
          "isPublic": "true",
          "servicePoints":[
            {
              "value": "#(servicePointId)",
              "label": "#(servicePointName)",
            },
          ] ,
        }
        """
      When method PUT
      Then status 404

    Scenario: Update a reading room when service point is associated with other reading room
      * print "Update a reading room when service point is associated with other reading room"
      * def readingRoomId = call uuid1
      * def readingRoomName = 'reading-room-2'
      * def servicePointId = call uuid1
      * def servicePointName = call random_string
      * def servicePointCode = call random_string
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')
      * def updatedName = 'reading-room-1-updated_f'
      Given path 'reading-room/' + '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
      And request
        """
        {
          "id": "3a40852d-49fd-4df2-a1f9-6e2641a6e71f",
          "name": "#(updatedName)",
          "isPublic": "true",
          "servicePoints":[
            {
              "value": "#(servicePointId)",
              "label": "#(servicePointName)",
            },
          ] ,
        }
        """
      When method PUT
      Then status 422


    Scenario: get all reading rooms
      * print "get all reading rooms includes both deleted and not deleted"
      * def readingRoomId = call uuid1
      * def readingRoomName = 'reading-room-3'
      * def servicePointId = call uuid1
      * def servicePointName = call random_string
      * def servicePointCode = call random_string
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')
      Given path 'reading-room'
      When method GET
      Then status 200
      And match response.readingRooms[2].name == "#(readingRoomName)"
      And match response.totalRecords == 3

    Scenario: search reading room by name
      * print "search reading room by name"
      Given path 'reading-room'
      And param query = '(name=reading-room-1-updated)'
      When method GET
      Then status 200
      And match response.readingRooms[0].name == "reading-room-1-updated"
      And match response.totalRecords == 1

    Scenario: search public reading rooms
      * print "search public reading rooms"
      Given path 'reading-room'
      And param query = '(isPublic=true)'
      When method GET
      Then status 200
      And match response.totalRecords == 1

    Scenario: search public reading rooms which are not deleted
      * print "search public reading rooms which are deleted"
      Given path 'reading-room'
      And param query = '(isPublic=true)'
      And param includeDeleted = false
      When method GET
      Then status 200
      And match response.totalRecords == 1

    Scenario: delete reading room
      * print "delete reading room"
      * def readingRoomId = call uuid1
      * def readingRoomName = 'reading-room-4_d'
      * def servicePointId = call uuid1
      * def servicePointName = call random_string
      * def servicePointCode = call random_string
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')
      Given path 'reading-room/' + readingRoomId
      When method DELETE
      Then status 204

    Scenario: delete reading room when readind room not exist
      * print "delete reading room when readind room not exist"
      * def notExistingReadingRoomId = call uuid1
      Given path 'reading-room/' + notExistingReadingRoomId
      When method DELETE
      Then status 404


    Scenario: get all reading rooms including deleted reading room (includeDeleted=true)
      * print "get all reading rooms including deleted reading room (includeDeleted=true)"
      * def readingRoomId = call uuid1
      * def readingRoomName = 'reading-room-5_d'
      * def servicePointId = call uuid1
      * def servicePointName = call random_string
      * def servicePointCode = call random_string
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
      * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')
      Given path 'reading-room/' + readingRoomId
      When method DELETE
      Then status 204

      Given path 'reading-room'
      And param includeDeleted = true
      When method GET
      Then status 200
      And match response.totalRecords == 5

    Scenario: get all reading rooms not including deleted reading room (includeDeleted=false)
      * print "get all reading rooms not including deleted reading room (includeDeleted=false)"
      Given path 'reading-room'
      And param includeDeleted = false
      When method GET
      Then status 200
      And match response.totalRecords == 3



