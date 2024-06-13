Feature: ReadingRoom tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * def readingRoomId = call uuid1
    * def readingRoomName = call random_string
    * def servicePointId = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string

  Scenario: Create a new reading room

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

  Scenario: Create a reading room which is already exist

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 409
    And match response.errors[0].message == 'Reading room with id ' + readingRoomId + ' already exists'

  Scenario: Create a reading room where service point is not found

    * def readingRoomName = 'reading-room-1_f'
    * def notExistingServicePointId = call uuid1
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.servicePoints[0].value = notExistingServicePointId
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'ServicePointId ' + notExistingServicePointId + ' doesn\'t exists in inventory'

  Scenario: Create a reading room where service point is already associated to other reading room

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def readingRoomId = call uuid1
    * def readingRoomName = readingRoomName
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'ServicePointId ' + servicePointId + ' already associated with another Reading room'

  Scenario: Update a reading room

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def readingRoomName = 'reading-room-1-updated'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.name = readingRoomName
    * readingRoomEntityRequest.isPublic = true
    Given path 'reading-room/' + readingRoomId
    And request readingRoomEntityRequest
    When method PUT
    Then status 200
    And match response.name == "#(readingRoomName)"

  Scenario: Update a reading room by adding another service point

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def readingRoomName = 'reading-room-1-updated'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.name = readingRoomName
    * readingRoomEntityRequest.isPublic = true

    * def servicePointId = call uuid1
    * def servicePointName = 'additional service point' + servicePointName
    * def servicePointCode = call random_string

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def newServicePoint = { "value": "#(servicePointId)", "label": "#(servicePointName)" }

    * readingRoomEntityRequest.servicePoints = karate.append(readingRoomEntityRequest.servicePoints, newServicePoint)

    Given path 'reading-room/' + readingRoomId
    And request readingRoomEntityRequest
    When method PUT
    Then status 200
    And match response.name == "#(readingRoomName)"

  Scenario: Update a reading room with id miss match
    * def differentId = call uuid1
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room/' + differentId
    And request readingRoomEntityRequest
    When method PUT
    Then status 422
    And match response.errors[0].message == 'The ID provided in the request URL does not match the ID of the resource in the request body'

  Scenario: Update a reading room when reading room not exist
    * def notExistingReadingRoomId = call uuid1
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.id = notExistingReadingRoomId
    Given path 'reading-room/' + notExistingReadingRoomId
    And request readingRoomEntityRequest
    When method PUT
    Then status 404
    And match response.errors[0].message == 'Reading room with id ' + notExistingReadingRoomId + ' doesn\'t exists'

  Scenario: Update a reading room when service point is associated with other reading room
    * def readingRoomId1 = call uuid1
    * def readingRoomName = 'reading-room-2'
    * def servicePointId1 = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = servicePointId1
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.id = readingRoomId1
    * readingRoomEntityRequest.servicePoints[0].value = servicePointId1
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def readingRoomId2 = call uuid1
    * def readingRoomName = 'reading-room-22'
    * def servicePointId2 = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = servicePointId2
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.id = readingRoomId2
    * readingRoomEntityRequest.servicePoints[0].value = servicePointId2
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

#    * def readingRoomId2 = call uuid1
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.id = readingRoomId2
    * readingRoomEntityRequest.name = 'reading-room-1-updated_f'
    * readingRoomEntityRequest.servicePoints[0].value = servicePointId1
    * readingRoomEntityRequest.servicePoints[0].label = servicePointName
    Given path 'reading-room/' + readingRoomId2
    And request readingRoomEntityRequest
    When method PUT
    Then status 422
    And match response.errors[0].message == 'ServicePointId ' + servicePointId1 + ' already associated with another Reading room'

  Scenario: get all reading rooms
    Given path 'reading-room'
    When method GET
    Then status 200

  Scenario: search reading room by name
    Given path 'reading-room'
    And param query = '(name=reading-room-1-updated)'
    When method GET
    Then status 200

  Scenario: search public reading rooms
    Given path 'reading-room'
    And param query = '(isPublic=true)'
    When method GET
    Then status 200

  Scenario: search public reading rooms which are not deleted
    Given path 'reading-room'
    And param query = '(isPublic=true)'
    And param includeDeleted = false
    When method GET
    Then status 200

  Scenario: delete reading room
    * def readingRoomName = 'reading-room-4_d'
    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    Given path 'reading-room/' + readingRoomId
    When method DELETE
    Then status 204

  Scenario: delete reading room when readind room not exist
    * def notExistingReadingRoomId = call uuid1
    Given path 'reading-room/' + notExistingReadingRoomId
    When method DELETE
    Then status 404
    And match response.errors[0].message == 'Reading room with id ' + notExistingReadingRoomId + ' doesn\'t exists'

  Scenario: get all reading rooms including deleted reading room (includeDeleted=true)
    Given path 'reading-room'
    And param includeDeleted = true
    When method GET
    Then status 200

  Scenario: get all reading rooms not including deleted reading room (includeDeleted=false)
    Given path 'reading-room'
    And param includeDeleted = false
    When method GET
    Then status 200

  Scenario: create access log

    * def servicePointEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/service-point/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 201

    * def accessLogId = call uuid1
    * def userId = '2205005b-ca51-4a04-87fd-938eefa8f6df'
    * def patronId = '2205005b-ca51-4a04-87fd-938eefa8f6df'
    * def accessLogEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/access-log/access-log-entity-request.json')
    Given path 'reading-room/'+ readingRoomId + '/access-log'
    And request accessLogEntityRequest
    When method POST
    Then status 201

    * def accessLogEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/access-log/access-log-entity-request.json')
    Given path 'reading-room/'+ readingRoomId + '/access-log'
    And request accessLogEntityRequest
    When method POST
    Then status 409
    And match response.errors[0].message == 'Access log with id ' + accessLogId + ' already exists'

  Scenario: create access log when reading room id missmatch
    * def differentReadingRoomId = call uuid1
    * def accessLogId = call uuid1
    * def userId = call uuid1
    * def patronId = call uuid1
    * def accessLogEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/access-log/access-log-entity-request.json')
    * accessLogEntityRequest.readingRoomId = differentReadingRoomId
    Given path 'reading-room/'+ readingRoomId + '/access-log'
    And request accessLogEntityRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'The reading room ID provided in the request URL does not match the ID of the resource in the request body'

