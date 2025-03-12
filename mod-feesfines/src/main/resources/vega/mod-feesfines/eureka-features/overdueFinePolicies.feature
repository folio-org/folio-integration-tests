Feature: Overdue fine policies tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def overdueFinePoliciesId = call uuid1

  # CRUD

  Scenario: Create an overdue fine policy
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 1"

    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { maxOverdueRecallFine: #present, gracePeriodRecall: #present, overdueRecallFine: #present, forgiveOverdueFine: #present, maxOverdueFine: #present, countClosed: #present, overdueFine: #present, metadata: #present, name: #present, description: #present, id: #present }

  Scenario: Get a list of overdue fine policies
    Given path 'overdue-fines-policies'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, overdueFinePolicies: #present }

  Scenario: Get an overdue fine policy by ID
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 2"
    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method GET
    Then status 200
    And match response == { maxOverdueRecallFine: #present, gracePeriodRecall: #present, overdueRecallFine: #present, forgiveOverdueFine: #present, maxOverdueFine: #present, countClosed: #present, overdueFine: #present, metadata: #present, name: #present, description: #present, id: #present }
    And match $.id == overdueFinePoliciesId

  Scenario: Update an overdue fine policy
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name= 'OFPN-FAT-4548'
    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method GET
    Then status 200
    And match $.id == overdueFinePoliciesId
    And match $.name == 'OFPN-FAT-4548'

    * requestEntity.name = "updated name"
    Given path 'overdue-fines-policies', overdueFinePoliciesId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method GET
    Then status 200
    And match $.id == overdueFinePoliciesId
    And match $.name == "updated name"

  Scenario: Delete an overdue fine policy
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 3"
    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method GET
    Then status 200

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method DELETE
    Then status 204

    Given path 'overdue-fines-policies', overdueFinePoliciesId
    When method GET
    Then status 404

  # Errors

  Scenario: Should return 422 when duplicate overdue fine policy is posted
    * def expectedErrMsg = "id value already exists in table overdue_fine_policy: " + overdueFinePoliciesId
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 4"

    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.name = "name 5"
    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  Scenario: Should return 422 when overdue fine policy with missing name is posted
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * remove requestEntity.name

    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'

  Scenario: Should return 422 when overdue fine policy with invalid UUID is posted
    * def expectedErrMsg = "must match \"^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[1-5][a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$\""
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 6"
    * requestEntity.id = 'invalid uuid'

    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  Scenario: Should return 400 when overdue fine policy is posted with incorrect x-okapi-tenant header
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }
    * def requestEntity = read('samples/policies/overdue-fine-policy-entity-request.json')
    * requestEntity.name = "name 7"

    Given path 'overdue-fines-policies'
    And request requestEntity
    When method POST
    Then status 400
    And match response contains 'Invalid Token: Failed to decode:Unrecognized token'
