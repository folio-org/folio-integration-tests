Feature: Query
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def loanEntityTypeId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    * def purchaseOrderLinesEntityTypeId = 'abc777d3-2a45-43e6-82cb-71e8c96d13d2'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def organizationsEntityTypeId = 'b5ffa2e9-8080-471a-8003-a8c5a1274503'

  Scenario: Post query
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    And match $.queryId == '#present'

  Scenario: Post query with invalid fql query should return 400 error
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$xy\": [\"missing\", \"lost\"]}}' }
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
    And match $.parameters[0].value == "Field invalid_field is not present in definition of entity type composite_item_details"

  Scenario: Get query results with query id
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    * print '## Get query results'
    Given path 'query/' + queryId
    When method GET
    Then status 200
    And match $.queryId == queryId
    And match $.fqlQuery == '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}'
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
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$regex\":\"integration_test_user_123\"}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    * print '## Cancel query'
    Given path 'query/' + queryId
    When method DELETE
    Then status 204
    * print '## Verify the query was cancelled'
    Given path 'query/' + queryId
    When method GET
    Then assert (responseStatus == 200 && response.status == "CANCELLED") || responseStatus == 404

  Scenario: Run a query on user preferred contact type
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"users.preferred_contact_type\":{\"$eq\":\"Email\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["users.preferred_contact_type"] == 'Email'

###### Disabled until querying array data is supported
#  Scenario: Run a query for on users' primary address and check that it displays correctly
#    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"users.primary_address\":{\"$regex\":\"^1234 Unique\"}}]}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#
#    Given path 'query/' + queryId
#    And params {includeResults: true, limit: 100, offset:0}
#    When method GET
#    Then status 200
#    And match $.content[0].user_primary_address == '1234 Unique Street, apt 102, Framingham, MA, 04222'
#
###### Disabled until querying array data is supported
#  Scenario: Run a query for on users' primary address with missing fields and check that it displays correctly
#    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"$and\":[{\"users.primary_address\":{\"$regex\":\"^9876 Unique\"}}]}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#
#    * def parameters = {includeResults: true, limit: 100, offset:0}
#    Given path 'query/' + queryId
#    And params parameters
#    When method GET
#    Then status 200
#    And match $.content[0].user_primary_address == '9876 Unique Street, Framingham, MA'

  Scenario: Run query with $eq operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"integration_test_user_123\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["users.id"] == '#present'
    And match $.content[0]["users.username"] == "integration_test_user_123"
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $ne operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$ne\":\"integration_test_user_456\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $gt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.created_date\": {\"$gt\":\"2020-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $lt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.created_date\": {\"$lt\":\"2040-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $in operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$in\":[\"integration_test_user_123\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $nin operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$nin\":[\"integration_test_user_456\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex starts_with operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$regex\":\"^integration_test\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    And match $.content contains deep {"users.username": 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex contains operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$regex\":\"test_user\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    And match $.content contains deep {"users.username": 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = true' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.middle_name\": {\"$empty\":true}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.middle_name":  '#notpresent'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = false' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$empty\": false}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": '#present'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

###### Disabled until querying array data is supported.
###### Additionally, there is a bug with $empty and object arrays that will need to be fixed for this test to pass (MODFQMMGR-372)
#  Scenario: Run query with '$empty = true' operator for an array field and check results (MODFQMMGR-119)
#    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.addresses\": {\"$empty\":true}}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#
#    Given path 'query/' + queryId
#    And params {includeResults: true, limit: 100, offset:0}
#    When method GET
#    Then status 200
#    And match $.content contains deep {user_regions:  '#notpresent'}
#    * def totalRecords = parseInt(response.totalRecords)
#    * assert totalRecords > 0

###### Disabled until querying array data is supported
###### Additionally, there is a bug with $empty and object arrays that will need to be fixed for this test to pass (MODFQMMGR-372)
#  Scenario: Run query with '$empty = false' operator for an array field and check results (MODFQMMGR-119)
#    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.addresses\": {\"$empty\": false}}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#
#    Given path 'query/' + queryId
#    And params {includeResults: true, limit: 100, offset:0}
#    When method GET
#    Then status 200
#    And match $.content contains deep {username: 'integration_test_user_with_full_address'}
#    And match $.content contains deep {user_regions: '#present'}
#    * def totalRecords = parseInt(response.totalRecords)
#    * assert totalRecords > 0

  @ignore
  Scenario: Get query results with entity-type-id and query as parameter
    * configure readTimeout = 60000
    Given path 'query'
    And params {entityTypeId: '#(userEntityTypeId)', query: '{\"users.username\": {\"$eq\": \"integration_test_user_123\"}}', fields: ['users.id', 'users.username']}
    When method GET
    Then status 200
    And match $.content[0]["users.username"] == 'integration_test_user_123'

  Scenario: Run a query on the loans entity type
    * def queryRequest = { entityTypeId: '#(loanEntityTypeId)' , fqlQuery: '{\"$and\":[{\"items.status_name\":{\"$eq\":\"Checked out\"}}, {\"loans.status_name\":{\"$eq\":\"Open\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"loans.status_name": 'Open', "items.status_name": 'Checked out'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the items entity type
    * def queryRequest = { entityTypeId: '#(itemEntityTypeId)' , fqlQuery: '{\"$and\":[{\"items.material_type_id\":{\"$in\":[\"2ee721ab-70e5-49a6-8b09-1af0217ea3fc\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"mtypes.name": 'book'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the instance entity type
    * def queryRequest = { entityTypeId: '#(instanceEntityTypeId)' , fqlQuery: '{\"$and\":[{\"instance.id\":{\"$nin\":[\"c8a2b47a-51f3-493b-9f9e-aaeb38ad804e\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200

  Scenario: Run a query on the purchase order lines entity type
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.payment_status\":{\"$eq\":\"Fully Paid\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"pol.payment_status": 'Fully Paid'}
    And match $.content contains deep {"pol.fund_distribution": '#(fundDistribution)'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the holdings entity type
    * def queryRequest = { entityTypeId: '#(holdingsEntityTypeId)' , fqlQuery: '{\"$and\":[{\"holdings.instance_id\":{\"$in\":[\"c8a1b47a-51f3-493b-9f9e-aaeb38ad804e\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"holdings.instance_id": 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the org info entity type
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)' , fqlQuery: '{\"$and\":[{\"status\":{\"$in\":[\"Active\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {status: 'Active'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

###### Disabled until querying array data is supported
#  Scenario: Run query with $contains_all operator and check results
#    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$contains_all\":[\"serials\"]}}]}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'
#
#    Given path 'query/' + queryId
#    And params {includeResults: true, limit: 100, offset:0}
#    When method GET
#    Then status 200
#    And match $.content contains deep {fund_distribution: '#(fundDistribution)'}
#    * def totalRecords = parseInt(response.totalRecords)
#    * assert totalRecords > 0

###### Disabled until querying array data is supported
#  Scenario: Run query with $not_contains_all operator and check results
#    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$not_contains_all\":[\"serials\", \"non_serials\"]}}]}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId
#    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'
#
#    Given path 'query/' + queryId
#    And params {includeResults: true, limit: 100, offset:0}
#    When method GET
#    Then status 200
#    And match $.content contains deep {fund_distribution: '#(fundDistribution)'}
#    * def totalRecords = parseInt(response.totalRecords)
#    * assert totalRecords > 0
#  Scenario: Should return _deleted field to indicate that a record has been deleted (MODFQMMGR-125)
#    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"user_to_delete\"}}' }
#    * def queryCall = call postQuery
#    * def queryId = queryCall.queryId

  Scenario: Run query with $contains_any operator and check results
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$contains_any\":[\"serials\", \"non_serials\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"pol.fund_distribution": '#(fundDistribution)'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $not_contains_any operator and check results
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$not_contains_any\":[\"serials\", \"non_serials\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200

  Scenario: Should return _deleted field to indicate that a record has been deleted (MODFQMMGR-125)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"user_to_delete\"}}' }
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