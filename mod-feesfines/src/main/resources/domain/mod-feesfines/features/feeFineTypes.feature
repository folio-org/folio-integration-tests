Feature: Fee/fine type tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def feefineId = call uuid1
    * def ownerId = call uuid1
    * def servicePointId = call uuid1

  # CRUD

  Scenario: Create a fee/fine type
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { metadata: #present, defaultAmount: #present, automatic: #present, id: #present, ownerId: #present, feeFineType: #present }

  Scenario: Get a list of fee/fine types
    Given path 'feefines'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, feefines: #present, resultInfo: #present }

  Scenario: Get a fee/fine type by ID
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefines', feefineId
    When method GET
    Then status 200
    And match response == { metadata: #present, defaultAmount: #present, automatic: #present, id: #present, ownerId: #present, feeFineType: #present }
    And match $.id == feefineId

  Scenario: Update a fee/fine type
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineRequestEntity
    When method POST
    Then status 201

    Given path 'feefines', feefineId
    When method GET
    Then status 200
    And match $.id == feefineId
    And match $.defaultAmount == 50

    * feefineRequestEntity.defaultAmount = 150
    Given path 'feefines', feefineId
    And request feefineRequestEntity
    When method PUT
    Then status 204

    Given path 'feefines', feefineId
    When method GET
    Then status 200
    And match $.id == feefineId
    And match $.defaultAmount == 150

  Scenario: Delete a fee/fine type
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefines', feefineId
    When method GET
    Then status 200
    And match $.id == feefineId

    Given path 'feefines', feefineId
    When method DELETE
    Then status 204

    Given path 'feefines', feefineId
    When method GET
    Then status 404

  Scenario: Cannot create a fee/fine type with duplicate IDs
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefines', feefineId
    When method GET
    Then status 200
    And match $.id == feefineId

    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 400
    And match response == "Unable to process request"

  Scenario: Cannot create a duplicate fee/fine type for the same owner
    Given path 'owners'
    And request
    """
    {
      "owner": "Folio Tester 1",
      "desc": "Test owner",
      "id": "20fb8c3c-5a95-4272-b1e6-7d8ad35868aa"
    }
    """
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    * remove requestEntity.id
    * requestEntity.ownerId = "20fb8c3c-5a95-4272-b1e6-7d8ad35868aa"

    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 400
    And match response == "Unable to process request"

  Scenario: Can create a duplicate fee/fine type for different owners
    Given path 'owners'
    And request
    """
    {
      "owner": "Folio Tester 2",
      "desc": "Test owner",
      "id": "20fb8c3c-5a95-4272-b1e6-7d8ad35868dd"
    }
    """
    When method POST
    Then status 201

    Given path 'owners'
    And request
    """
    {
      "owner": "Folio Tester 3",
      "desc": "Test owner",
      "id": "20fb8c3c-5a95-4272-b1e6-7d8ad35868bb"
    }
    """
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefine-request-entity.json')
    * remove requestEntity.id
    * requestEntity.ownerId = "20fb8c3c-5a95-4272-b1e6-7d8ad35868dd"

    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.ownerId = "20fb8c3c-5a95-4272-b1e6-7d8ad35868bb"
    Given path 'feefines'
    And request requestEntity
    When method POST
    Then status 201
