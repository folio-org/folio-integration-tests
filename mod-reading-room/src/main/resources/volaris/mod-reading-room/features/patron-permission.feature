Feature: PatronPermission tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json','x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * call read('classpath:common/util/uuid1.feature')
    * call read('classpath:common/util/random_string.feature')
    * call read('classpath:common/util/random_numbers.feature')
    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-1'
    * def servicePointId = call uuid1
    * def servicePointName = call random_string
    * def servicePointCode = call random_string
    * def patronPermissionId = call uuid1
    * def userId = call uuid1
    * def status = true
    * def lastName = call random_string
    * def firstName = call random_string
    * def username = call random_string
    * def email = 'abc@pqr.com'
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = userId
    * def patronId = call uuid1
    * def patronName = call random_string

  Scenario: update patron permission

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

    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + userId
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

    * def readingRoomId = call uuid1
    * def readingRoomName = 'reading-room-2'
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')
    Given path 'reading-room-patron-permission/' + userId
    And request patronPermissionEntityRequest
    When method PUT
    Then status 409

  Scenario: get patron permissions when no permissions are present
    * def username = call random_string
    * def barcode = call random_numbers
    * def uuid = call uuid1

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

    Given path 'reading-room-patron-permission/' + uuid
    When method GET
    Then status 200

  Scenario: get patron permissions by passing service point
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

    Given path 'reading-room-patron-permission/' + userId
    And param servicePointId = servicePointId
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

    * def patronPermissionId = call uuid1
    * def patronPermissionEntityRequest = read('classpath:volaris/mod-reading-room/features/samples/patron-permission/patron-permission-entity-request.json')

    Given path 'reading-room-patron-permission/' + userId
    And request patronPermissionEntityRequest
    When method PUT
    Then status 200

    Given path 'reading-room-patron-permission/' + userId
    When method GET
    Then status 200

    Given path 'reading-room/' + readingRoomId
    When method DELETE
    Then status 204

    Given path 'reading-room-patron-permission/' + userId
    When method GET
    Then status 200