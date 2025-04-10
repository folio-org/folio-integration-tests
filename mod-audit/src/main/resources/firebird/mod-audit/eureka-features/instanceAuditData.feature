Feature: instance audit data

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def modifyDataPath = 'classpath:firebird/mod-audit/eureka-util/init-data.feature'

  Scenario: check audit data for new Instance creation
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def auditData = call read(modifyDataPath + '@GetInstanceAuditData') { instanceId:'#(instanceId)' }
    * def response = auditData.response
    And match response.totalRecords == 1
    And match response.inventoryAuditItems[0].entityId == '#(instanceId)'
    And match response.inventoryAuditItems[0].action == 'CREATE'

  Scenario: check audit data for Instance update
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def instance = call read(modifyDataPath + '@GetInstance') { instanceId:'#(instanceId)' }
    And def createdInstance = instance.response

    * print "update 'title' field and add 'editions' field"
    * eval createdInstance['title'] = "TestInstanceTitleUpdated"
    * eval createdInstance['editions'] = ["Editions Added"]
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * def diffModifiedAdded =
      """
      {
        "fieldChanges" : [
          {
            "changeType" : "MODIFIED",
            "fieldName" : "title",
            "fullPath" : "title",
            "oldValue" :  "TestInstance",
            "newValue" : "TestInstanceTitleUpdated"
          } ],
        "collectionChanges" : [{
          "collectionName": "editions",
          "itemChanges": [{
            "changeType": "ADDED",
            "newValue": "Editions Added"
          }
          ]
        }
        ]
      }
      """

    * print "check audit data action and diff"
    Given def auditData = call read(modifyDataPath + '@GetInstanceAuditData') { instanceId:'#(instanceId)' }
    * def response = auditData.response
    And match response.totalRecords == 2
    And match response.inventoryAuditItems[0].entityId == '#(instanceId)'
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffModifiedAdded
    And match response.inventoryAuditItems[1].entityId == '#(instanceId)'
    And match response.inventoryAuditItems[1].action == 'CREATE'

    Given def instance = call read(modifyDataPath + '@GetInstance') { instanceId:'#(instanceId)' }
    And def updatedInstance = instance.response

    * print "remove 'editions' field"
    * eval updatedInstance['editions'] = []
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(updatedInstance)' }
    * def diffRemoved =
      """
      {
        "fieldChanges": [],
        "collectionChanges": [{
          "collectionName": "editions",
          "itemChanges": [{
            "changeType": "REMOVED",
            "oldValue": "Editions Added"
          }
          ]
        }
        ]
      }
      """

    * print "check audit data action and diff"
    Given def auditData = call read(modifyDataPath + '@GetInstanceAuditData') { instanceId:'#(instanceId)' }
    * def response = auditData.response
    And match response.totalRecords == 3
    And match response.inventoryAuditItems[0].entityId == '#(instanceId)'
    And match response.inventoryAuditItems[0].action == 'UPDATE'
    And match response.inventoryAuditItems[0].diff == diffRemoved
    And match response.inventoryAuditItems[1].action == 'UPDATE'
    And match response.inventoryAuditItems[1].diff == diffModifiedAdded
    And match response.inventoryAuditItems[2].action == 'CREATE'

  Scenario: check instance audit data pagination
    Given def instance = call read(modifyDataPath + '@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    Given def instance = call read(modifyDataPath + '@GetInstance') { instanceId:'#(instanceId)' }
    And def createdInstance = instance.response

    * print "update title 11 times"
    * eval createdInstance['title'] = "TestInstanceTitleUpdated1"
    * eval createdInstance['_version'] = "1"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated2"
    * eval createdInstance['_version'] = "2"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated3"
    * eval createdInstance['_version'] = "3"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated4"
    * eval createdInstance['_version'] = "4"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated5"
    * eval createdInstance['_version'] = "5"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated6"
    * eval createdInstance['_version'] = "6"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated7"
    * eval createdInstance['_version'] = "7"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated8"
    * eval createdInstance['_version'] = "8"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated9"
    * eval createdInstance['_version'] = "9"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated10"
    * eval createdInstance['_version'] = "10"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }
    * eval createdInstance['title'] = "TestInstanceTitleUpdated11"
    * eval createdInstance['_version'] = "11"
    * call read(modifyDataPath + '@UpdateInstance') { instanceId: '#(instanceId)', instance: '#(createdInstance)' }

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
    Given def auditData = call read(modifyDataPath + '@GetInstanceAuditData') { instanceId:'#(instanceId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == pageSize

    * updatedSetting.value = 5
    Given def updatedPageSizeSetting = call read(modifyDataPath + '@PutPageSizeAuditData') { setting:'#(updatedSetting)' }
    * def updatedPageSize = updatedPageSizeSetting.setting.value
    And match updatedPageSize == 5

    * print "check inventoryAuditItems size should be equal to pageSize from setting"
    Given def auditData = call read(modifyDataPath + '@GetInstanceAuditData') { instanceId:'#(instanceId)' }
    * def response = auditData.response
    And match response.totalRecords == 12
    And assert karate.sizeOf(response.inventoryAuditItems) == updatedPageSize

