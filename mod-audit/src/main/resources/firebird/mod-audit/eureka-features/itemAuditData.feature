Feature: item audit data

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def modifyDataPath = 'classpath:firebird/mod-audit/eureka-util/init-data.feature'

  Scenario: check audit data for new Item creation
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id

    Given def items = call read(modifyDataPath + '@CreateItems') { holdingsId:'#(holdingId)' }
    And def itemId = items.id
    * def item = items.response

    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 1
    And match response.inventoryAuditItems[0].entityId == '#(itemId)'
    And match response.inventoryAuditItems[0].action == 'CREATE'

  Scenario: check audit data for Item update
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id

    Given def items = call read(modifyDataPath + '@CreateItems') { holdingsId:'#(holdingId)' }
    And def itemId = items.id
    * def item = items.response

    * print "update 'displaySummary' field and add 'administrativeNotes' field"
    * item.administrativeNotes = ["Note added"]
    * item.displaySummary = "Display summary updated"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * def diffModifiedAdded =
      """
      {
        "fieldChanges": [{
          "changeType": "MODIFIED",
          "fieldName": "displaySummary",
          "fullPath": "displaySummary",
          "oldValue": "Display summary",
          "newValue": "Display summary updated"
        }
        ],
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
    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 2
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffModifiedAdded
    And match response.inventoryAuditItems[1].action == 'CREATE'

    Given def item = call read(modifyDataPath + '@GetItem') { itemId:'#(itemId)' }
    And def updatedItem = item.response

    * print "remove 'displaySummary' field"
    * updatedItem.displaySummary = null
    * call read(modifyDataPath + '@UpdateItem') { item:'#(updatedItem)', itemId:'#(itemId)' }
    * def diffRemoved =
      """
      {
        "fieldChanges": [{
          "changeType": "REMOVED",
          "fieldName": "displaySummary",
          "fullPath": "displaySummary",
          "oldValue": "Display summary updated"
        }
        ],
        "collectionChanges": []
      }
      """

    * print "check audit data action and diff"
    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 3
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffRemoved
    And match response.inventoryAuditItems[1].action == 'UPDATE'
    And match response.inventoryAuditItems[1].diff == diffModifiedAdded
    And match response.inventoryAuditItems[2].action == 'CREATE'

  Scenario: check audit data for Item deletion
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id

    Given def items = call read(modifyDataPath + '@CreateItems') { holdingsId:'#(holdingId)' }
    And def itemId = items.id
    * def item = items.response

    * call read(modifyDataPath + '@DeleteItem') { itemId:'#(itemId)' }

    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 2
    And match response.inventoryAuditItems[0].action == 'DELETE'
    And match response.inventoryAuditItems[1].action == 'CREATE'

  Scenario: check item audit data pagination
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def holdings = call read(modifyDataPath + '@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingId = holdings.id
    * def holding = holdings.response

    Given def items = call read(modifyDataPath + '@CreateItems') { holdingsId:'#(holdingId)' }
    And def itemId = items.id
    * def item = items.response

    # update displaySummary 11 times
    * item.displaySummary = "Display summary updated1"
    * item['_version'] = "1"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated2"
    * item['_version'] = "2"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated3"
    * item['_version'] = "3"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated4"
    * item['_version'] = "4"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated5"
    * item['_version'] = "5"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated6"
    * item['_version'] = "6"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated7"
    * item['_version'] = "7"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated8"
    * item['_version'] = "8"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated9"
    * item['_version'] = "9"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated10"
    * item['_version'] = "10"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }
    * item.displaySummary = "Display summary updated11"
    * item['_version'] = "11"
    * call read(modifyDataPath + '@UpdateItem') { item:'#(item)', itemId:'#(itemId)' }

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
    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == pageSize

    * updatedSetting.value = 5
    Given def updatedPageSizeSetting = call read(modifyDataPath + '@PutPageSizeAuditData') { setting:'#(updatedSetting)' }
    * def updatedPageSize = updatedPageSizeSetting.setting.value
    And match updatedPageSize == 5

    * print "check inventoryAuditItems size should be equal to pageSize from setting"
    Given def auditData = call read(modifyDataPath + '@GetItemAuditData') { itemId:'#(itemId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == updatedPageSize
