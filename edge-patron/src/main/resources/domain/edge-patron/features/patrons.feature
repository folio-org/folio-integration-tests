Feature: patron tests

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def firstName = call random_string
    * def lastName = call random_string
    * def owner = random_string
    * def amount = call random_numbers
    * def status = 'Available'
    * def requestId = call random_uuid
    * def servicePointId = call random_uuid
    * def materialTypeId = call random_uuid
    * callonce read('classpath:domain/edge-patron/features/util/initData.feature@postMaterialType')

  Scenario: Return total fees/fines regardless of fee/fine being attached to an item for a patron.
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.createUserRequest.id
    * def extSystemId = createUserResponse.createUserRequest.externalSystemId
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def itemId = createItemResponse.itemEntityRequest.id
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine')
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine')
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndCharges')

    Given url edgeUrl
    And path 'patron/account/' + extSystemId
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalCharges.amount == 15
    And match response.totalChargesCount == 3

  Scenario: Return loans for a patron
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.createUserRequest.id
    * def userBarcode = createUserResponse.createUserRequest.barcode
    * def extSystemId = createUserResponse.createUserRequest.externalSystemId
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostPolicies')
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def itemId = createItemResponse.itemEntityRequest.id
    * def itemBarcode = createItemResponse.itemEntityRequest.barcode
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostCheckOut')

    Given url edgeUrl
    And path 'patron/account/' + extSystemId+ '?includeLoans=true'
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalLoans == 1
    And match response.loans[0].item.itemId == itemId

  Scenario: Return fees/fines per item for a patron
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser')
    * def userId = createUserResponse.createUserRequest.id
    * def userBarcode = createUserResponse.createUserRequest.barcode
    * def extSystemId = createUserResponse.createUserRequest.externalSystemId
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def itemId = createItemResponse.itemEntityRequest.id
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostOwnerAndFine')

    Given url edgeUrl
    And path 'patron/account/' + extSystemId + '?includeCharges=true'
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.totalChargesCount == 1
    And match response.charges[0].item.itemId == itemId


  Scenario: Return requests for a patron
    * call read('classpath:domain/edge-patron/features/util/initData.feature@PostPolicies')
    * def status = 'Checked out'
    * def createItemResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostItem')
    * def itemId = createItemResponse.itemEntityRequest.id
    * def itemBarcode = createItemResponse.itemEntityRequest.barcode
    * def servicePointId = createItemResponse.servicePointEntityRequest.id
    * def createUserResponse = call read('classpath:domain/edge-patron/features/util/initData.feature@PostPatronGroupAndUser')
    * def requesterId = createUserResponse.createUserRequest.id
    * def extSystemId = createUserResponse.createUserRequest.externalSystemId
    * def requestEntityRequest = read('classpath:domain/edge-patron/features/samples/request/request-entity-request.json')

    Given path 'circulation/requests'
    And headers headers
    And request requestEntityRequest
    When method POST
    Then status 201

    Given url edgeUrl
    And path 'patron/account/' + extSystemId +'?includeHolds=true'
    And param apikey = apikey
    When method GET
    Then status 200
    Then match response.totalHolds == 1
    And match response.holds[0].item.itemId == itemId
