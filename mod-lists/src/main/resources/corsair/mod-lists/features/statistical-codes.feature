Feature: Scenarios that are primarily focused around filtering instances by statistical code

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'
    * def statisticalCodeSourceEntityTypeId = 'd2da8cc7-9171-4d3e-8aba-4da286eb5f1c'
    * def booksStatisticalCodeId = 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    * def booksStatisticalCodeLabel = 'ARL (Collection stats): books - Book, print (books)'
    * def ptfStatisticalCodeId = '8d1f5e72-e0a4-42b1-9de9-2d9452ecc46d'
    * def ptfStatisticalCodeLabel = 'PTF: PTF5 - PTF5'
    * def matchingInstanceTitle = 'Second statistical code instance'

  @C506656
  Scenario: Create and refresh an instance list using the instance statistical code field
    # Verify the instance statistical code field metadata exposed by FQM
    Given path 'entity-types'
    When method GET
    Then status 200
    * def instanceEntityTypeSummary = response.entityTypes.find(entityType => entityType.id == instanceEntityTypeId)
    * match instanceEntityTypeSummary == '#present'

    Given path 'entity-types', instanceEntityTypeId
    When method GET
    Then status 200
    And match $.id == instanceEntityTypeId
    And match $.name == 'composite_instances'
    * def statisticalCodeField = response.columns.find(column => column.name == 'instance.statistical_code_names')
    * match statisticalCodeField == '#present'
    * match statisticalCodeField.queryable == true
    * match statisticalCodeField.idColumnName == 'instance.statistical_code_ids'
    * match statisticalCodeField.source.entityTypeId == statisticalCodeSourceEntityTypeId
    * match statisticalCodeField.source.columnName == 'statistical_code'

    # Verify the available statistical code values used to build the list query
    Given path 'entity-types', instanceEntityTypeId, 'field-values'
    And param field = 'instance.statistical_code_names'
    When method GET
    Then status 200
    * def selectedStatisticalCode = response.content.find(option => option.value == booksStatisticalCodeId && option.label == booksStatisticalCodeLabel)
    * def matchingStatisticalCode = response.content.find(option => option.value == ptfStatisticalCodeId && option.label == ptfStatisticalCodeLabel)
    * match selectedStatisticalCode == '#present'
    * match matchingStatisticalCode == '#present'

    # Create the list, refresh it, and verify the matching instance content
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/instance-list.json')
    * listRequest.name = 'Instance Statistical Code List ' + randomMillis()
    * listRequest.description = listRequest.name
    * listRequest.fqlQuery = JSON.stringify({ "instance.statistical_code_names": { "$nin": [selectedStatisticalCode.value] } })
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList { listId: '#(listId)' }

    * def pollingAttempts = 0
    * def maxPollingAttempts = 3
    Given path 'lists', listId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.successRefresh != null)
    When method GET
    Then status 200
    And match $.successRefresh == '#present'

    * def query = { offset: 0, size: 100, fields: ['instance.title', 'instance.statistical_code_names'] }
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.content[0]["instance.title"] == matchingInstanceTitle
    And match $.content[0]["instance.statistical_code_names"] == ['#(matchingStatisticalCode.label)']
