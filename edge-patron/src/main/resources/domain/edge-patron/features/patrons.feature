Feature: patron tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = {  'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def uuid = call random_uuid
    * def firstName = call random_string
    * def lastName = call random_string
    * def owner = random_string
    * def amount = call random_numbers
    * def status = 'Available'
    * def requestId = call random_uuid
    * def servicePointId = call random_uuid

  Scenario: Return total fees/fines regardless of fee/fine being attached to an item for a patron.
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem') { itemId: 388830d5-95db-4528-95b6-4ec9d37d4086, materialTypeId: 388830d5-95db-4528-95b6-4ec9d37d4087,materialTypeName: TestMaterial, itemBarcode: 11111}
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')  { itemId: 388830d5-95db-4528-95b6-4ec9d37d4056, materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4086,materialTypeName: TestMaterial1, itemBarcode: 2222}
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine'){ materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4089, itemId: 388830d5-95db-4528-95b6-4ec9d37d4056 }
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine'){ materialTypeId: 188830d5-95db-4528-95b6-4ec9d34d4086, itemId: 388830d5-95db-4528-95b6-4ec9d37d4086 }
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser') { userBarcode: 1111,username:  testUser1}
    * def userId = createUserResponse.createUserRequest.id

    Given path 'patron/account/' + userId
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalCharges.amount == amount+amount

  Scenario: Return loans for a patron
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser') { userBarcode: 2222,username: testUser2}
    * def userId = createUserResponse.createUserRequest.id
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostPolicies')
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')  { itemId: 388830d5-95db-4528-95b6-4ec9d37d4057, materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4090, materialTypeName: TestMaterial2, itemBarcode: 3333}
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostCheckOut') { itemBarcode: 3333,userBarcode: 2222 }

    Given path 'patron/account/' + userId
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalLoans == 1

  Scenario: Return fees/fines per item for a patron
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser') { userBarcode: 3333,username:  testUser3}
    * def userId = createUserResponse.createUserRequest.id
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')  { itemId: 388830d5-95db-4528-95b6-4ec9d37d4058, materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4091,materialTypeName: TestMaterial3, itemBarcode: 4444}
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine') {barcode: 3333,materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4091, itemId: 388830d5-95db-4528-95b6-4ec9d37d4058 }

    Given path 'patron/account/' + userId + '?includeCharges=true'
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalChargesCount == 1
    And match response..itemId == ['388830d5-95db-4528-95b6-4ec9d37d4058']
    And match response..reason == ['lost']

  Scenario: Return requests for a patron
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostPolicies')
    * def status = 'Checked out'
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')  { itemId: 388830d5-95db-4528-95b6-4ec9d37d4059, materialTypeId: 388830d5-95db-4528-95b6-4ec9d34d4092,materialTypeName: TestMaterial4, itemBarcode: 5555}
    * def itemId = createItemResponse.itemEntityRequest.id
    * def itemBarcode = createItemResponse.itemEntityRequest.barcode
    * def servicePointId = createItemResponse.servicePointEntityRequest.id
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser') { userBarcode: 4444,username:  testUser4}
    * def requesterId = createUserResponse.createUserRequest.id
    * def requestEntityRequest = read('classpath:domain/edge-patron/features/samples/request/request-entity-request.json')

    Given path 'circulation' ,'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    Given path 'patron/account/' + requesterId + '?includeHolds=true'
    And param apikey = apikey
    When method GET
    Then status 200
    Then match response.totalHolds == 1
    And match response..itemId == ['388830d5-95db-4528-95b6-4ec9d37d4059']
