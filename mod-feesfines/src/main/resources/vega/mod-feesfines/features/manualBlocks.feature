Feature: Manual blocks tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def userId = call uuid1
    * def manualblockId = call uuid1

  # CRUD

  Scenario: Create a manual block
    * def requestEntity = read('samples/manualblock-request-entity.json')

    Given path 'manualblocks'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { metadata: #present, desc: #present, id: #present, userId: #present }

  Scenario: Get a list of manual blocks
    Given path 'manualblocks'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, manualblocks: #present }

  Scenario: Get a manual block by ID
    * def requestEntity = read('samples/manualblock-request-entity.json')
    Given path 'manualblocks'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manualblocks', manualblockId
    When method GET
    Then status 200
    And match response.id == manualblockId
    And match response == { metadata: #present, id: #present, userId: #present, desc: #present }

  Scenario: Update a manual block
    * def requestEntity = read('samples/manualblock-request-entity.json')
    Given path 'manualblocks'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manualblocks', manualblockId
    When method GET
    Then status 200
    And response.desc == 'default description'

    * requestEntity.desc = 'updated description'
    Given path 'manualblocks', manualblockId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'manualblocks', manualblockId
    When method GET
    Then status 200
    And response.desc == 'updated description'

  Scenario: Delete a manual block
    * def requestEntity = read('samples/manualblock-request-entity.json')
    Given path 'manualblocks'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'manualblocks', manualblockId
    When method GET
    Then status 200
    And match response.id == manualblockId

    Given path 'manualblocks', manualblockId
    When method DELETE
    Then status 204

    Given path 'manualblocks', manualblockId
    When method GET
    Then status 404
    And match response == 'ManualblockObject does not exist'
