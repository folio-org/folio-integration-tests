Feature: Query array operators
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    * def purchaseOrderLinesEntityTypeId = 'abc777d3-2a45-43e6-82cb-71e8c96d13d2'

    # ##### Disabled until querying array data is supported.
    # ##### Additionally, there is a bug with $empty and object arrays that will need to be fixed for this test to pass (MODFQMMGR-372)
    #  Scenario: Run query with '$empty = true' operator for an array field and check results (MODFQMMGR-119)
    #    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.addresses\": {\"$empty\":true}}' }
    #    * def queryCall = call postQuery
    #    * def queryId = queryCall.queryId

    #    Given path 'query/' + queryId
    #    And params {includeResults: true, limit: 100, offset:0}
    #    When method GET
    #    Then status 200
    #    And match $.content contains deep {user_regions: null}
    #    * def totalRecords = parseInt(response.totalRecords)
    #    * assert totalRecords > 0

    # ##### Disabled until querying array data is supported
    # ##### Additionally, there is a bug with $empty and object arrays that will need to be fixed for this test to pass (MODFQMMGR-372)
    #  Scenario: Run query with '$empty = false' operator for an array field and check results (MODFQMMGR-119)
    #    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.addresses\": {\"$empty\": false}}' }
    #    * def queryCall = call postQuery
    #    * def queryId = queryCall.queryId

    #    Given path 'query/' + queryId
    #    And params {includeResults: true, limit: 100, offset:0}
    #    When method GET
    #    Then status 200
    #    And match $.content contains deep {username: 'integration_test_user_with_full_address'}
    #    And match $.content contains deep {user_regions: '#present'}
    #    * def totalRecords = parseInt(response.totalRecords)
    #    * assert totalRecords > 0

    # ##### Disabled until querying array data is supported
    #  Scenario: Run query with $contains_all operator and check results
    #    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$contains_all\":[\"serials\"]}}]}' }
    #    * def queryCall = call postQuery
    #    * def queryId = queryCall.queryId
    #    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    #    Given path 'query/' + queryId
    #    And params {includeResults: true, limit: 100, offset:0}
    #    When method GET
    #    Then status 200
    #    And match $.content contains deep {fund_distribution: '#(fundDistribution)'}
    #    * def totalRecords = parseInt(response.totalRecords)
    #    * assert totalRecords > 0

    # ##### Disabled until querying array data is supported
    #  Scenario: Run query with $not_contains_all operator and check results
    #    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$not_contains_all\":[\"serials\", \"non_serials\"]}}]}' }
    #    * def queryCall = call postQuery
    #    * def queryId = queryCall.queryId
    #    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    #    Given path 'query/' + queryId
    #    And params {includeResults: true, limit: 100, offset:0}
    #    When method GET
    #    Then status 200
    #    And match $.content contains deep {fund_distribution: '#(fundDistribution)'}
    #    * def totalRecords = parseInt(response.totalRecords)
    #    * assert totalRecords > 0

  Scenario: Should return _deleted field to indicate that a record has been deleted (MODFQMMGR-125)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"user_to_delete\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

  Scenario: Run query with $contains_any operator and check results
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$contains_any\":[\"serials\", \"non_serials\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "distributionType": "percentage"}]'

    Given path 'query', queryId
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

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
