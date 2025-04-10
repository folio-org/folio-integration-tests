Feature: holding audit data

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def modifyDataPath = 'classpath:firebird/mod-audit/eureka-util/init-data.feature'

  Scenario: check audit data for new Holding creation
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id
    And def holding = holdings.response

    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 1
    And match response.inventoryAuditItems[0].entityId == '#(holdingId)'
    And match response.inventoryAuditItems[0].action == 'CREATE'

  Scenario: check audit data for Holding update
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id
    And def holding = holdings.response

    * print "update 'shelvingTitle' field and add 'administrativeNotes' field"
    * holding.administrativeNotes = ["Note added"]
    * holding.shelvingTitle = "Shelving title updated"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * def diffModifiedAdded =
      """
      {
        "fieldChanges": [
          {
            "changeType" : "MODIFIED",
            "fieldName" : "shelvingTitle",
            "fullPath" : "shelvingTitle",
            "oldValue" :  "Shelving title",
            "newValue" : "Shelving title updated"
          }],
        "collectionChanges": [{
          "collectionName": "administrativeNotes",
          "itemChanges": [{
            "changeType": "ADDED",
            "newValue": "Note added"
          }
          ]
        }
        ]
      }
      """

    * print "check audit data action and diff"
    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 2
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffModifiedAdded
    And match response.inventoryAuditItems[1].action == 'CREATE'

    Given def holding = call read(modifyDataPath + '@GetHolding') { holdingId:'#(holdingId)' }
    And def updatedHolding = holding.response

    * print "remove 'shelvingTitle' field"
    * updatedHolding.shelvingTitle = null
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(updatedHolding)', holdingId:'#(holdingId)' }
    * def diffRemoved =
      """
      {
        "fieldChanges": [{
          "changeType": "REMOVED",
          "fieldName": "shelvingTitle",
          "fullPath": "shelvingTitle",
          "oldValue": "Shelving title updated"
        }
        ],
        "collectionChanges": []
      }
      """

    * print "check audit data action and diff"
    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 3
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffRemoved
    And match response.inventoryAuditItems[1].action == 'UPDATE'
    And match response.inventoryAuditItems[1].diff == diffModifiedAdded
    And match response.inventoryAuditItems[2].action == 'CREATE'

  Scenario: check audit data for Holding deletion
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id
    And def holding = holdings.response

    * call read(modifyDataPath + '@DeleteHolding') { holdingId:'#(holdingId)' }

    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 2
    And match response.inventoryAuditItems[0].action == 'DELETE'
    And match response.inventoryAuditItems[1].action == 'CREATE'

  Scenario: check holding audit data pagination
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id
    * def holding = holdings.response

    * print "update shelvingTitle 11 times"
    * holding.shelvingTitle = "Shelving title updated1"
    * holding['_version'] = "1"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated2"
    * holding['_version'] = "2"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated3"
    * holding['_version'] = "3"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated4"
    * holding['_version'] = "4"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated5"
    * holding['_version'] = "5"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated6"
    * holding['_version'] = "6"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated7"
    * holding['_version'] = "7"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated8"
    * holding['_version'] = "8"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated9"
    * holding['_version'] = "9"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated10"
    * holding['_version'] = "10"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }
    * holding.shelvingTitle = "Shelving title updated11"
    * holding['_version'] = "11"
    * call read(modifyDataPath + '@UpdateHolding') { holding:'#(holding)', holdingId:'#(holdingId)' }

    * def updatedSetting =
      """
      {
        "key": "records.page.size",
        "value": 10,
        "type": "INTEGER",
        "groupId": "audit.inventory"
      }
      """
    Given def updatedPageSizeSetting = call read(modifyDataPath + '@PutPageSizeAuditData') { setting:'#(updatedSetting)' }
    * def updatedPageSize = updatedPageSizeSetting.setting.value
    And match updatedPageSize == 10

    * print "check pagination settings for audit.inventory (records.page.size)"
    Given def auditDataSttings = call read(modifyDataPath + '@GetPageSizeAuditData')
    * def pageSize = karate.filter(auditDataSttings.response.settings, function(x){ return x.key == 'records.page.size' })[0].value
    And match pageSize == 10

    * print "check inventoryAuditItems size should be equal to pageSize from setting"
    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == pageSize

    * updatedSetting.value = 5
    Given def updatedPageSizeSetting = call read(modifyDataPath + '@PutPageSizeAuditData') { setting:'#(updatedSetting)' }
    * def updatedPageSize = updatedPageSizeSetting.setting.value
    And match updatedPageSize == 5

    * print "check inventoryAuditItems size should be equal to pageSize from setting"
    Given def auditData = call read(modifyDataPath + '@GetHoldingAuditData') { holdingId:'#(holdingId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == updatedPageSize
