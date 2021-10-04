Feature: Lost item fee policies tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def lostItemFeePolicyId = call uuid1

  # CRUD

  Scenario: Create a lost item fee policy
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.name = 'name 1'
    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { metadata: #present, name: #present, description: #present, id: #present }

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 200
    And match $.id == lostItemFeePolicyId

  Scenario: Get a list of lost item fee policies
    Given path 'lost-item-fees-policies'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, lostItemFeePolicies: #present }

  Scenario: Get a lost item fee policy by ID
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.name = 'name 2'
    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { metadata: #present, name: #present, description: #present, id: #present }

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 200
    And match response == { metadata: #present, name: #present, description: #present, id: #present }
    And match response.id == lostItemFeePolicyId

  Scenario: Update a lost item fee policy
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.name = 'name 3'
    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 201
    And match response.description == "default description"

    * requestEntity.description = "updated description"
    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 200
    And match response.id == lostItemFeePolicyId
    And match response.description == "updated description"

  Scenario: Delete a lost item fee policy
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.name = 'name 4'
    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 200

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method DELETE
    Then status 204

    Given path 'lost-item-fees-policies', lostItemFeePolicyId
    When method GET
    Then status 404

  # Errors

  Scenario: Should return 422 when duplicate lost item fee policy is posted
    * def expectedErrMsg = 'id value already exists in table lost_item_fee_policy: ' + lostItemFeePolicyId

    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.name = 'name 5'
    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  Scenario: Should return 422 when lost item fee policy with missing name is posted
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * remove requestEntity.name

    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == "must not be null"

  Scenario: Should return 422 when lost item fee policy with invalid UUID is posted
    * def expectedErrMsg = "must match \"^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[1-5][a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$\""
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')
    * requestEntity.id = "invalid uuid"

    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  Scenario: Should return 400 when lost item fee policy is posted with incorrect x-okapi-tenant header
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }
    * def requestEntity = read('samples/lost-item-fee-policy-request-entity.json')

    Given path 'lost-item-fees-policies'
    And request requestEntity
    When method POST
    Then status 400
    And match response contains 'Invalid Token: Failed to decode:Unrecognized token'
