Feature: PatronPermission tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * call read('classpath:common/util/random_numbers.feature')
    * def readingRoomId = '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    * def readingRoomName = 'reading-room-1'
    * def servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'
    * def servicePointName = 'test service point'
    * def servicePointCode = 'test'
    * def patronPermissionId = call uuid1
    * def userId = '2205005b-ca51-4a04-87fd-938eefa8f6df'
    * def patronId = '2205005b-ca51-4a04-87fd-938eefa8f6df'
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'

  Scenario: update patron permission
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = userId
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostPatronGroupAndUser')
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + '2205005b-ca51-4a04-87fd-938eefa8f6df'
    And request patronPermissionEntityRequest
    When method PUT
    Then status 200

  Scenario: update patron permission when patron id mismatch with user ids of the patron permission
    * def patronId = call uuid1
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + patronId
    And request patronPermissionEntityRequest
    When method PUT
    Then status 400
    And match response.errors[0].message == 'patronId does not match with userIds of PatronPermissions'

  Scenario: update patron permission when user not found with given patron id
    * def userId = '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    And request patronPermissionEntityRequest
    When method PUT
    Then status 500
    And match response.errors[0].message == 'patronId does not exist in users record'

  Scenario: update patron permission with not existing reading room
    * print 'update patron permission with not existing reading room'
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-2'
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + patronId
    And request patronPermissionEntityRequest
    When method PUT
    Then status 409

  Scenario: get patron permissions when no permissions are present
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = '81e09a31-a22d-415e-a68b-ae3b49e49db0'
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostPatronGroupAndUser')
    Given path 'reading-room-patron-permission/' + '81e09a31-a22d-415e-a68b-ae3b49e49db0'
    When method GET
    Then status 200

  Scenario: get patron permissions when some permissions are present by not passing service point
    Given path 'reading-room-patron-permission/' + patronId
    When method GET
    Then status 200

  Scenario: get patron permissions by passing service point
    Given path 'reading-room-patron-permission/' + patronId
    And param servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'
    When method GET
    Then status 200

  Scenario: get patron permissions when patron does not exist
    * def patronId = call uuid1
    Given path 'reading-room-patron-permission/' + patronId
    When method GET
    Then status 500
    And match response.errors[0].message == 'patronId does not exist in users record'

  Scenario: get patron permissions when reading room is deleted
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-deleted'
    * def servicePointId = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostServicePoint')
    * call read('classpath:volaris/mod-reading-room/features/util/initData.feature@PostReadingRoom')

    * def patronPermissionId = call uuid1
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')

    Given path 'reading-room-patron-permission/' + '2205005b-ca51-4a04-87fd-938eefa8f6df'
    And request patronPermissionEntityRequest
    When method PUT
    Then status 200

    Given path 'reading-room-patron-permission/' + '2205005b-ca51-4a04-87fd-938eefa8f6df'
    When method GET
    Then status 200

    Given path 'reading-room/' + readingRoomId
    When method DELETE
    Then status 204

    Given path 'reading-room-patron-permission/' + '2205005b-ca51-4a04-87fd-938eefa8f6df'
    When method GET
    Then status 200