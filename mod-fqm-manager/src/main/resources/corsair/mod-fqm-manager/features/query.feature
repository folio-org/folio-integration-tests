Feature: Query
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def itemEntityTypeId = '0cb79a4c-f7eb-4941-a104-745224ae0292'
    * def loanEntityTypeId = '4e09d89a-44ed-418e-a9cc-820dfb27bf3a'
    * def userEntityTypeId = '0069cf6f-2833-46db-8a51-8934769b8289'
    * def purchaseOrderLinesEntityTypeId = '90403847-8c47-4f58-b117-9a807b052808'

  Scenario: Post query
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"item_status\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    And match $.queryId == '#present'

  Scenario: Post query with invalid fql query should return 400 error
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"item_status\": {\"$xy\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].value == "Condition {\"$xy\":[\"missing\",\"lost\"]} contains an invalid operator"

  Scenario: Post query with invalid column name should return 400 error
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"invalid_field\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].key == "invalid_field"
    And match $.parameters[0].value == "Field invalid_field is not present in definition of entity type drv_item_details"

  Scenario: Get query results with query id
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"item_status\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    Given path 'query/' + queryId
    When method GET
    Then status 200
    And match $.queryId == queryId
    And match $.fqlQuery == '{\"item_status\": {\"$in\": [\"missing\", \"lost\"]}}'
    And match $.entityTypeId == '#present'
    And match $.status == '#present'
    And match $.totalRecords == '#present'

  Scenario: Post query without required parameters should throw '400 Bad Gateway' Response
    Given path 'query'
    When method POST
    Then status 400

  Scenario: Get query with invalid queryId should return '404 Not Found' Response
    * def invalidId = call uuid1
    Given path 'query/' + invalidId
    When method GET
    Then status 404

  Scenario: Cancel query
    Given path 'query'
    And request { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$regex\":\"integration_test_user_123\"}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    Given path 'query/' + queryId
    When method DELETE
    Then status 204
    Given path 'query/' + queryId
    When method GET
    Then assert (responseStatus == 200 && response.status == "CANCELLED") || responseStatus == 404

  Scenario: Run a query on user preferred contact type
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"user_preferred_contact_type\":{\"$eq\":\"Email\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0].user_preferred_contact_type == 'Email'

  Scenario: Run a query for on users' primary address and check that it displays correctly
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"user_primary_address\":{\"$regex\":\"^1234 Unique\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0].user_primary_address == '1234 Unique Street, apt 102, Framingham, MA, 04222'

  Scenario: Run a query for on users' primary address with missing fields and check that it displays correctly
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"user_primary_address\":{\"$regex\":\"^9876 Unique\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content[0].user_primary_address == '9876 Unique Street, Framingham, MA'

  Scenario: Run query with $eq operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$eq\":\"integration_test_user_123\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0].id == '#present'
    And match $.content[0].username == "integration_test_user_123"
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $ne operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$ne\":\"integration_test_user_456\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $gt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"user_created_date\": {\"$gt\":\"2020-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $lt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"user_created_date\": {\"$lt\":\"2040-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $in operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$in\":[\"integration_test_user_123\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $nin operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$nin\":[\"integration_test_user_456\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex starts_with operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$regex\":\"^integration_test\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    And match $.content contains deep {username: 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex contains operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$regex\":\"test_user\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    And match $.content contains deep {username: 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = true' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"user_middle_name\": {\"$empty\":true}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {user_middle_name:  '#notpresent'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = false' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$empty\": false}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: '#present'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = true' operator for an array field and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"user_regions\": {\"$empty\":true}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {user_regions:  '#notpresent'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = false' operator for an array field and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"user_regions\": {\"$empty\": false}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_with_full_address'}
    And match $.content contains deep {user_regions: '#present'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Get query results with entity-type-id and query as parameter
    * configure readTimeout = 60000
    Given path 'query'
    And params {entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289', query: '{\"username\": {\"$eq\": \"integration_test_user_123\"}}', fields: ['id', 'username']}
    When method GET
    Then status 200
    And match $.content[0].username == 'integration_test_user_123'

  Scenario: Run a query on the loans entity type
    * def queryRequest = { entityTypeId: '#(loanEntityTypeId)' , fqlQuery: '{\"$and\":[{\"item_status\":{\"$eq\":\"Checked out\"}}, {\"loan_status\":{\"$eq\":\"Open\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {loan_status: 'Open', item_status: 'Checked out'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the items entity type
    * def queryRequest = { entityTypeId: '#(itemEntityTypeId)' , fqlQuery: '{\"$and\":[{\"item_material_type\":{\"$in\":[\"book\", \"movie\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {item_material_type: 'book'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the purchase order lines entity type
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"purchase_order_line_payment_status\":{\"$eq\":\"Fully Paid\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {purchase_order_line_payment_status: 'Fully Paid'}
    And match $.content contains deep {fund_distribution: '#(fundDistribution)'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Should return _deleted field to indicate that a record has been deleted (MODFQMMGR-125)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$eq\":\"user_to_delete\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'users/00000000-1111-2222-9999-44444444444'
    When method DELETE
    Then status 204

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0] contains {"_deleted":  true}

  Scenario: Purge queries for a tenant
    Given path 'query/purge'
    When method POST
    Then status 200