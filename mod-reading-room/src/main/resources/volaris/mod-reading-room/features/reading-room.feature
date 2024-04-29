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
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')

  Scenario: Create a reading room which is already exist
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 409
    And match response.errors[0].message == 'Reading room with id ' + readingRoomId + ' already exists'

  Scenario: Create a reading room where service point is not found
    * def readingRoomId = call uuid1
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
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-2_f'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    Given path 'reading-room'
    And request readingRoomEntityRequest
    When method POST
    Then status 422
    And match response.errors[0].message == 'ServicePointId ' + servicePointId + ' already associated with another Reading room'

  Scenario: Update a reading room
    * def readingRoomName = 'reading-room-1-updated'
    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.name = readingRoomName
    * readingRoomEntityRequest.isPublic = true
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
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-2'
    * def servicePointId = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')

    * def readingRoomEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/reading-room/reading-room-entity-request.json')
    * readingRoomEntityRequest.id = '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    * readingRoomEntityRequest.name = 'reading-room-1-updated_f'
    * readingRoomEntityRequest.servicePoints[0].value = servicePointId
    * readingRoomEntityRequest.servicePoints[0].label = servicePointName
    Given path 'reading-room/' + '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    And request readingRoomEntityRequest
    When method PUT
    Then status 422
    And match response.errors[0].message == 'ServicePointId ' + servicePointId + ' already associated with another Reading room'

  Scenario: get all reading rooms
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
    Given path 'reading-room'
    And param query = '(name=reading-room-1-updated)'
    When method GET
    Then status 200
    And match response.readingRooms[0].name == "reading-room-1-updated"
    And match response.totalRecords == 1

  Scenario: search public reading rooms
    Given path 'reading-room'
    And param query = '(isPublic=true)'
    When method GET
    Then status 200
    And match response.totalRecords == 1

  Scenario: search public reading rooms which are not deleted
    Given path 'reading-room'
    And param query = '(isPublic=true)'
    And param includeDeleted = false
    When method GET
    Then status 200
    And match response.totalRecords == 1

  Scenario: delete reading room
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
    * def notExistingReadingRoomId = call uuid1
    Given path 'reading-room/' + notExistingReadingRoomId
    When method DELETE
    Then status 404
    And match response.errors[0].message == 'Reading room with id ' + notExistingReadingRoomId + ' doesn\'t exists'

  Scenario: get all reading rooms including deleted reading room (includeDeleted=true)
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
    Given path 'reading-room'
    And param includeDeleted = false
    When method GET
    Then status 200
    And match response.totalRecords == 3