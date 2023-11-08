Feature: Query
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def itemEntityTypeId = '0cb79a4c-f7eb-4941-a104-745224ae0292'
    * def loanEntityTypeId = '4e09d89a-44ed-418e-a9cc-820dfb27bf3a'
    * def userEntityTypeId = '0069cf6f-2833-46db-8a51-8934769b8289'

  Scenario: Post query
    Given path 'query'
    And request { entityTypeId: '0cb79a4c-f7eb-4941-a104-745224ae0292', fqlQuery: '{\"item_status\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    And match $.queryId == '#present'

  Scenario: Invalid fql query should return 400 error
    Given path 'query'
    And request { entityTypeId: '0cb79a4c-f7eb-4941-a104-745224ae0292', fqlQuery: '{\"item_status\": {\"$xy\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].value == "Condition {\"$xy\":[\"missing\",\"lost\"]} contains an invalid operator"

  Scenario: Invalid column name should return 400 error
    Given path 'query'
    And request { entityTypeId: '0cb79a4c-f7eb-4941-a104-745224ae0292', fqlQuery: '{\"invalid_field\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].key == "invalid_field"
    And match $.parameters[0].value == "Field invalid_field is not present in definition of entity type drv_item_details"

  Scenario: Get query results with query id
    Given path 'query'
    And request { entityTypeId: '0cb79a4c-f7eb-4941-a104-745224ae0292' , fqlQuery: '{\"item_status\": {\"$in\": [\"missing\", \"lost\"]}}' }
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

  Scenario: Cancelling the query with query id
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
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * def queryRequest = { entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289' , fqlQuery: '{\"$and\":[{\"user_preferred_contact_type\":{\"$eq\":\"Email\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0].user_preferred_contact_type == 'Email'

  Scenario: Run a query for on users' primary address and check that it displays correctly
    * def addressRequest = {addressType:  'Home address', id:  '12349f82-a4ef-47ca-b29c-0a5ad7bbf321'}
    Given path '/addresstypes'
    And request addressRequest
    When method POST
    Then status 201
    * def addressId = $.id

    * def userRequest = read('samples/user-request-with-address.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    * def queryRequest = { entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289' , fqlQuery: '{\"$and\":[{\"user_primary_address\":{\"$regex\":\"^1234 Unique\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query/' + queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0].user_primary_address == '1234 Unique Street, apt 102, Framingham, MA, 04222'

    Given path '/users/' + userId
    When method DELETE
    Then status 204

    Given path '/addresstypes/' + addressId
    When method DELETE
    Then status 204

##  # needs new user logic
  Scenario: Run a query for on users' primary address with missing fields and check that it displays correctly
    * def addressRequest = {addressType:  'Home address', id:  '12349f82-a4ef-47ca-b29c-0a5ad7bbf321'}
    Given path '/addresstypes'
    And request addressRequest
    When method POST
    Then status 201
    * def addressId = $.id

    * def userRequest = read('samples/user-request-missing-address-fields.json')
    Given path '/users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    * def queryRequest = { entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289' , fqlQuery: '{\"$and\":[{\"user_primary_address\":{\"$regex\":\"^9876 Unique\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content[0].user_primary_address == '9876 Unique Street, Framingham, MA'

    Given path '/users/' + userId
    When method DELETE
    Then status 204

    Given path '/addresstypes/' + addressId
    When method DELETE
    Then status 204

  Scenario: Run query with $eq operator and check results
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

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
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

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

  #### HERE

  Scenario: Run query with $gt operator and check results
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

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
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

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
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$in\":[\"integration_test_user_123\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $nin operator and check results
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$nin\":[\"integration_test_user_456\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex starts_with operator and check results
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$regex\":\"^integration_test\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    And match $.content contains deep {username: 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  # regex contains
  Scenario: Run query with $regex contains operator and check results
    * def userIds = []
    * configure afterScenario = () => karate.call("util/delete-users.feature", userIds)
    * def userRequest = read('samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId1 = $.id
    * set userIds[0] = {userId: '#(userId1)'}

    * userRequest.username = 'integration_test_user_456'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId2 = $.id
    * set userIds[1] = {userId: '#(userId2)'}

    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"username\": {\"$regex\":\"test_user\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    * def parameters = {includeResults: true, limit: 100, offset:0}
    Given path 'query/' + queryId
    And params parameters
    When method GET
    Then status 200
    And match $.content contains deep {username: 'integration_test_user_123'}
    And match $.content contains deep {username: 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Get query results with entity-type-id and query as parameter
    * def userRequest = read('samples/user-request.json')
    Given path '/users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    * configure readTimeout = 60000
    Given path 'query'
    * def params = {entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289', query: '{\"username\": {\"$eq\": \"integration_test_user_123\"}}' }
    And params params
    When method GET
    Then status 200
    And match $.content[0].id == userId

    Given path '/users/' + userId
    When method DELETE
    Then status 204

  Scenario: Purge queries for a tenant
    Given path 'query/purge'
    When method POST
    Then status 200

