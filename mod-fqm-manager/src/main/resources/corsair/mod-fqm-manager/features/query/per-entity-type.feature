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
    * def itemDamagedStatusId = 'c1312672-0000-4000-8000-000000000001'
    * def fqmPoCheckboxFieldName = 'po._custom_field_83195700-0000-4000-8000-000000000001'
    * def fqmPoMultiSelectFieldName = 'po._custom_field_83195700-0000-4000-8000-000000000002'
    * def fqmPoSingleSelectFieldName = 'po._custom_field_83195700-0000-4000-8000-000000000003'
    * def fqmPoTextAreaFieldName = 'po._custom_field_83195700-0000-4000-8000-000000000004'
    * def fqmPoTextFieldFieldName = 'po._custom_field_83195700-0000-4000-8000-000000000005'

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

  @Positive @C1312672
  Scenario: Verify item condition data is available and queryable
    * def conditionResultFields = ['items.id', 'items.missing_pieces', 'items.missing_pieces_date', 'items.number_of_missing_pieces', 'items.item_damaged_status', 'items.item_damaged_status_date']

    Given path 'entity-types', itemEntityTypeId
    When method GET
    Then status 200
    And match response.columns[*].name contains conditionResultFields

    * def fqlQuery = '{\"$and\":[{\"items.missing_pieces\":{\"$starts_with\":\"Piece\"}},{\"items.missing_pieces_date\":{\"$eq\":\"2026-04-19\"}},{\"items.number_of_missing_pieces\":{\"$ne\":\"200\"}},{\"items.item_damaged_status\":{\"$in\":[\"' + itemDamagedStatusId + '\"]}},{\"items.item_damaged_status_date\":{\"$eq\":\"2026-04-19\"}}]}'
    * configure retry = { count: 24, interval: 5000 }
    Given path 'query'
    And params { entityTypeId: '#(itemEntityTypeId)', query: '#(fqlQuery)', fields: '#(conditionResultFields)' }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords == 1
    * def conditionRow = response.content[0]
    * match conditionRow["items.missing_pieces"] == 'Piece 1 - test'
    * match conditionRow["items.missing_pieces_date"] == '2026-04-19'
    * assert parseInt(conditionRow["items.number_of_missing_pieces"]) == 100
    * match conditionRow["items.item_damaged_status"] == 'Damaged'
    * match conditionRow["items.item_damaged_status_date"] == '2026-04-19'

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

  @C844854
  Scenario: Query purchase order lines by fund distribution details
    * def fields = ['pol.fund_distribution']
    * def fqlQuery = '{\"$and\":[{\"pol.fund_distribution[*]->code\":{\"$in\":[\"CANHIST\", \"EXCH-SUBN\", \"MISCHIST\"]}},{\"pol.fund_distribution[*]->fund_name\":{\"$eq\":\"History Misc\"}},{\"pol.fund_distribution[*]->distribution_type\":{\"$nin\":[\"amount\"]}}]}'
    * def expectedFundDistribution = '[{"code": "CANHIST", "value": 30.0, "fundId": "c8448540-0000-4000-8000-000000000003", "fund_name": "Canadian History", "distributionType": "percentage", "expense_class_name": null}, {"code": "EXCH-SUBN", "value": 30.0, "fundId": "c8448540-0000-4000-8000-000000000004", "fund_name": "Exchanges", "distributionType": "percentage", "expense_class_name": null}, {"code": "MISCHIST", "value": 40.0, "fundId": "c8448540-0000-4000-8000-000000000005", "fund_name": "History Misc", "distributionType": "percentage", "expense_class_name": null}]'
    * configure retry = { count: 24, interval: 5000 }
    Given path 'query'
    And params { entityTypeId: '#(purchaseOrderLinesEntityTypeId)', query: '#(fqlQuery)', fields: '#(fields)' }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords == 1
    And match response.content[0]['pol.fund_distribution'] == expectedFundDistribution

  @C831957
  Scenario: Verify label aliases are displayed for inherited purchase order custom fields
    * configure retry = { count: 90, interval: 5000 }
    Given path 'entity-types', purchaseOrderLinesEntityTypeId
    And retry until response.columns && response.columns.some(column => column.name == fqmPoTextFieldFieldName)
    When method GET
    Then status 200
    * def checkboxColumn = response.columns.find(column => column.name == fqmPoCheckboxFieldName)
    * def multiSelectColumn = response.columns.find(column => column.name == fqmPoMultiSelectFieldName)
    * def singleSelectColumn = response.columns.find(column => column.name == fqmPoSingleSelectFieldName)
    * def textAreaColumn = response.columns.find(column => column.name == fqmPoTextAreaFieldName)
    * def textFieldColumn = response.columns.find(column => column.name == fqmPoTextFieldFieldName)
    * assert checkboxColumn != null
    * assert multiSelectColumn != null
    * assert singleSelectColumn != null
    * assert textAreaColumn != null
    * assert textFieldColumn != null
    * def customFieldLabels = karate.map([checkboxColumn, multiSelectColumn, singleSelectColumn, textAreaColumn, textFieldColumn], function(column) { return column.labelAlias })
    And match customFieldLabels contains only ['PO — FQM - checkbox', 'PO — FQM - multi select', 'PO — FQM - single select', 'PO — FQM - text area', 'PO — FQM - text field']
    * def customFieldLabelsJson = karate.toJson(customFieldLabels)
    And match customFieldLabelsJson !contains '_custom_field_'
    And match customFieldLabelsJson !contains 'customfield'

    * def checkboxQuery = '{"' + fqmPoCheckboxFieldName + '":{"$eq":"true"}}'
    * def multiSelectQuery = '{"' + fqmPoMultiSelectFieldName + '":{"$nin":["opt_1"]}}'
    * def singleSelectQuery = '{"' + fqmPoSingleSelectFieldName + '":{"$in":["opt_1"]}}'
    * def textAreaQuery = '{"' + fqmPoTextAreaFieldName + '":{"$eq":"FQM test for text area"}}'
    * def textFieldQuery = '{"' + fqmPoTextFieldFieldName + '":{"$contains":"test"}}'
    * def customFieldQuery = '{"$and":[' + checkboxQuery + ',' + multiSelectQuery + ',' + singleSelectQuery + ',' + textAreaQuery + ',' + textFieldQuery + ']}'
    * def customFieldResultFields = []
    * set customFieldResultFields[0] = fqmPoCheckboxFieldName
    * set customFieldResultFields[1] = fqmPoMultiSelectFieldName
    * set customFieldResultFields[2] = fqmPoSingleSelectFieldName
    * set customFieldResultFields[3] = fqmPoTextAreaFieldName
    * set customFieldResultFields[4] = fqmPoTextFieldFieldName
    * def queryRequest = { entityTypeId: '#(purchaseOrderLinesEntityTypeId)', fqlQuery: '#(customFieldQuery)', fields: '#(customFieldResultFields)' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset: 0}
    When method GET
    Then status 200
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0
    * def matchingRows = karate.filter(response.content, function(row) { return row[fqmPoSingleSelectFieldName] == 'FQM - single select2' && row[fqmPoTextAreaFieldName] == 'FQM test for text area' && row[fqmPoTextFieldFieldName] == 'FQM test for text field' })
    * assert matchingRows.length > 0
    * def matchingRow = matchingRows[0]
    * def matchingCheckboxValue = matchingRow[fqmPoCheckboxFieldName]
    * def matchingMultiSelectValue = matchingRow[fqmPoMultiSelectFieldName]
    * match matchingCheckboxValue == 'true'
    * match matchingMultiSelectValue contains 'FQM - multi select1'

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

  @C1282799
  Scenario: Query loans by user department
    * def queryRequest = { entityTypeId: '#(loanEntityTypeId)' , fqlQuery: '{"users.departments":{"$in":["310f6067-4fd0-5108-a589-cb429c5c7973"]},"_version":"24"}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["users.departments"] contains 'Test department'
