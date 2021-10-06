Feature: Fee/fine actions tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def accountId = call uuid1
    * def userId = call uuid1
    * def feeFineActionId = call uuid1
    * def feefineId = call uuid1
    * def ownerId = call uuid1
    * def servicePointId = call uuid1

  # CRUD

  Scenario: Create a fee/fine action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefineactions-request-entity.json')
    Given path 'feefineactions'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { accountId: #present, id: #present, typeAction: #present, userId: #present, notify: #present }

  Scenario: Get a list of fee/fine actions
    Given path 'feefineactions'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, feefineactions: #present }

  Scenario: Get a fee/fine action by ID
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefineactions-request-entity.json')
    Given path 'feefineactions'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefineactions', feeFineActionId
    When method GET
    Then status 200
    And match response.id == feeFineActionId
    And match response == { accountId: #present, id: #present, typeAction: #present, userId: #present, notify: #present }

  Scenario: Update a fee/fine action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefineactions-request-entity.json')
    * requestEntity.typeAction = "custom typeAction"
    Given path 'feefineactions'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefineactions', feeFineActionId
    When method GET
    Then status 200
    And match response.id == feeFineActionId
    And match response.typeAction == 'custom typeAction'

    * requestEntity.typeAction = "updated typeAction"
    Given path 'feefineactions', feeFineActionId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'feefineactions', feeFineActionId
    When method GET
    Then status 200
    And match response.id == feeFineActionId
    And match response.typeAction == 'updated typeAction'

  Scenario: Delete a fee/fine action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def requestEntity = read('samples/feefineactions-request-entity.json')
    * requestEntity.typeAction = "custom typeAction"
    Given path 'feefineactions'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'feefineactions', feeFineActionId
    When method GET
    Then status 200

    Given path 'feefineactions', feeFineActionId
    When method DELETE
    Then status 204

    Given path 'feefineactions', feeFineActionId
    When method GET
    Then status 404
    And match response == 'FeefineactionObject does not exist'
