Feature: Query each entity type
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def loanEntityTypeId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'
    * def purchaseOrderLinesEntityTypeId = 'abc777d3-2a45-43e6-82cb-71e8c96d13d2'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def organizationsEntityTypeId = 'e0ea4212-4023-458a-adce-8003ff6c5d9e'

  Scenario: Run a query on the loans entity type
    * def queryRequest = { entityTypeId: '#(loanEntityTypeId)' , fqlQuery: '{\"$and\":[{\"items.status_name\":{\"$eq\":\"Checked out\"}}, {\"loans.status_name\":{\"$eq\":\"Open\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
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
    Given path 'query', queryId
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
    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200

  Scenario: Run a query on the purchase order lines entity type
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)' , fqlQuery: '{\"$and\":[{\"pol.payment_status\":{\"$eq\":\"Fully Paid\"}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    * def fundDistribution = '[{"code": "serials", "value": 100.0, "fundId": "692bc717-e37a-4525-95e3-fa25f58ecbef", "fund_name": null, "distributionType": "percentage", "expense_class_name": null}]'

    Given path 'query', queryId
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
    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"holdings.instance_id": 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run a query on the org info entity type
    * def queryRequest = { entityTypeId: '#(organizationsEntityTypeId)' , fqlQuery: '{\"$and\":[{\"organization.status\":{\"$in\":[\"Active\"]}}]}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId
    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"organization.status": 'Active'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0
