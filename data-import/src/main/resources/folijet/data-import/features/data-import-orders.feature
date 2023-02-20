Feature: Test Data-Import holdings records

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def defaultPoLineLimit = 2
    * def vendorId = "c6dace5d-4574-411e-8ba1-036102fcdc9b"

  @Ignore
  @ImportOrderWithNoOtherAction
  Scenario: import order single action
    # Create mapping profile for create order
    * def mappingProfileName = "FAT-3047: MARC-TO-ORDER mapping profile, single action " + uniqueID
    * def orderStatusWithQuotes = "\"" + orderStatus + "\""
    * def createInventory = "\"None\""
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/order-import-mapping-profile.json')
    When method POST
    Then status 201
    * def createOrderMappingProfileId = $.id

    # Create action profile for create order
    * def folioRecordNameAndDescription = "FAT-3047: MARC-TO-ORDER action profile, single action " + uniqueID
    * def folioRecord = 'ORDER'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createOrderMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createOrderActionProfileId = $.id

    # Create job profile - Create Order
    * def createJobProfileName = "FAT-3047: Create Order job profile " + uniqueID
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(createJobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createOrderActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          }
        ],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Import file and create order
    * def jobProfileId = createJobProfileId
    * def fileName = mrcFile
    Given call read(utilFeature+'@ImportRecord') { jobName: 'customJob' }
    Then match status != 'ERROR'

  @Ignore
  @ImportOrderWithMultipleActions
  Scenario: import order multiple action
    * def mappingProfileName = 'FAT-3047: MARC-TO-INSTANCE mapping profile, multiple actions ' + uniqueID
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": []
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createInstanceMappingProfileId = $.id

    * def folioRecordNameAndDescription = 'FAT-3047: MARC-TO-INSTANCE action profile, multiple actions ' + uniqueID
    * def folioRecord = 'INSTANCE'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createInstanceActionProfileId = $.id

    * def mappingProfileName = 'FAT-3047: MARC-TO-HOLDINGS mapping profile, multiple actions ' + uniqueID
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name" : "permanentLocationId",
                "enabled" : "true",
                "path" : "holdings.permanentLocationId",
                "value" : "\"Main Library (KU/CC/DI/M)\"",
                "subfields" : [ ],
                "acceptedValues" : {
                  "fcd64ce1-6995-48f0-840e-89ffa2288371" : "Main Library (KU/CC/DI/M)"
                }
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createHoldingsMappingProfileId = $.id

    * def folioRecordNameAndDescription = 'FAT-3047: MARC-TO-HOLDINGS action profile, multiple actions ' + uniqueID
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createHoldingsActionProfileId = $.id

    * def mappingProfileName = 'FAT-3047: MARC-TO-ITEM mapping profile, multiple actions ' + uniqueID
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "ITEM",
          "description": "",
          "mappingDetails": {
            "name": "item",
            "recordType": "ITEM",
            "mappingFields": [
              {
                "name" : "materialType.id",
                "enabled" : "true",
                "path" : "item.materialType.id",
                "value" : "\"book\"",
                "subfields" : [ ],
                "acceptedValues" : {
                  "1a54b431-2e4f-452d-9cae-9cee66c9a892" : "book",
                  "d9acad2f-2aac-4b48-9097-e6ab85906b25" : "text",
                  "5ee11d91-f7e8-481d-b079-65d708582ccc" : "dvd",
                  "30b3e36a-d3b2-415e-98c2-47fbdf878862" : "video recording",
                  "615b8413-82d5-4203-aa6e-e37984cb5ac3" : "electronic resource",
                  "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1" : "sound recording",
                  "fd6c6515-d470-4561-9c32-3e3290d4ca98" : "microform",
                  "71fbd940-1027-40a6-8a48-49b44d795e46" : "unspecified"
                }
              },
              {
                "name" : "permanentLoanType.id",
                "enabled" : "true",
                "path" : "item.permanentLoanType.id",
                "value" : "\"Can circulate\"",
                "subfields" : [ ],
                "acceptedValues" : {
                  "2e48e713-17f3-4c13-a9f8-23845bb210a4" : "Reading room",
                  "2b94c631-fca9-4892-a730-03ee529ffe27" : "Can circulate",
                  "e8b311a6-3b21-43f2-a269-dd9310cb2d0e" : "Course reserves",
                  "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845" : "Selected"
                }
              },
              {
                "name" : "status.name",
                "enabled" : "true",
                "path" : "item.status.name",
                "value" : "\"Available\"",
                "subfields" : [ ]
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createItemMappingProfileId = $.id

    * def folioRecordNameAndDescription = 'FAT-3047: MARC-TO-ITEM action profile, multiple actions ' +  uniqueID
    * def folioRecord = 'ITEM'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createItemActionProfileId = $.id

    # Create mapping profile for create order status
    * def mappingProfileName = "FAT-3047: MARC-TO-ORDER mapping profile, multiple actions " + uniqueID
    * def orderStatusWithQuotes = "\"" + orderStatus + "\""
    * def createInventory = ""
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/order-import-mapping-profile.json')
    When method POST
    Then status 201
    * def createOrderMappingProfileId = $.id

    # Create action profile for create order
    * def folioRecordNameAndDescription = 'FAT-3047: MARC-TO-ORDER action profile, multiple actions ' + uniqueID
    * def folioRecord = 'ORDER'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createOrderMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createOrderActionProfileId = $.id

    # Create job profile - Create Order
    * def createJobProfileName = "FAT-3047: Create Order, Holdings, Instance, Item job profile " + uniqueID
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(createJobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createOrderActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createInstanceActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createHoldingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 2
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createItemActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 3
          }
        ],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createdJobProfileId = $.id

    # Import file and create order
    * def jobProfileId = createdJobProfileId
    * def fileName = mrcFile
    Given call read(utilFeature+'@ImportRecord') { jobName: 'customJob' }
    Then match status != 'ERROR'

  @SetDefaultPoLinesLimit
  Scenario: set default poLinesLimit in config
    Given path 'configurations/entries'
    And headers headersUser
    And request
    """
    {
      "module": "ORDERS",
      "configName": "poLines-limit",
      "enabled": true,
      "value": "#(defaultPoLineLimit)"
    }
    """
    When method POST
    Then status 201

  Scenario: FAT-3047 Test import pending order, no other actions in profile, use default POLines limit
    * def uniqueID = "pending order"
    * def orderStatus = "Pending"
    * def overridePoLinesLimit = ""
    * def mrcFile = "FAT-3047"

    * call read('@ImportOrderWithNoOtherAction')

    # Verify job execution for create pending order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].poLineActionStatus == "CREATED"
    And match response.entries[1].poLineActionStatus == "CREATED"
    * def firstSourceRecordId = response.entries[0].sourceRecordId
    * def secondSourceRecordId = response.entries[1].sourceRecordId

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def firstRecordPoLineId = response.relatedPoLineInfo.idList[0]
    * def firstRecordOrderId = response.relatedPoLineInfo.orderId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def secondRecordPoLineId = response.relatedPoLineInfo.idList[0]
    And match response.relatedPoLineInfo.orderId == firstRecordOrderId
    And match secondRecordPoLineId != firstRecordPoLineId

    # Check mapping result order
    Given path 'orders/composite-orders', firstRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result first poLine
    Given path 'orders/order-lines', firstRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Pending"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId

    # Check mapping result second poLine
    Given path 'orders/order-lines', secondRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Pending"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId

  Scenario: FAT-3047 Test import open order, no other actions in profile, use default POLines limit
    * def uniqueID = "open order"
    * def orderStatus = "Open"
    * def overridePoLinesLimit = ""
    * def mrcFile = "FAT-3047"

    * call read('@ImportOrderWithNoOtherAction')

    # Verify job execution for create open order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].poLineActionStatus == "CREATED"
    And match response.entries[1].poLineActionStatus == "CREATED"
    * def firstSourceRecordId = response.entries[0].sourceRecordId
    * def secondSourceRecordId = response.entries[1].sourceRecordId

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def firstRecordPoLineId = response.relatedPoLineInfo.idList[0]
    * def firstRecordOrderId = response.relatedPoLineInfo.orderId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def secondRecordPoLineId = response.relatedPoLineInfo.idList[0]
    And match response.relatedPoLineInfo.orderId == firstRecordOrderId
    And match secondRecordPoLineId != firstRecordPoLineId

    # Check mapping result order
    Given path 'orders/composite-orders', firstRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result first poLine
    Given path 'orders/order-lines', firstRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Awaiting Payment"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId

    # Check mapping result second poLine
    Given path 'orders/order-lines', secondRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Awaiting Payment"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId

  Scenario: FAT-3047 Test import pending order, inventory actions specified in the Profile are disregarded, override POLines limit
    * def orderStatus = "Pending"
    * def uniqueID = "pending order"
    * def mrcFile = "FAT-3047"
    * def overridePoLinesLimit = "\"1\""

    * call read('@ImportOrderWithMultipleActions')

    # Verify job execution for create pending order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == 'CREATED'
    And match response.entries[0].instanceActionStatus == '#notpresent'
    And match response.entries[0].holdingsActionStatus == '#notpresent'
    And match response.entries[0].itemActionStatus == '#notpresent'
    And match response.entries[0].poLineActionStatus == 'CREATED'

    * def firstSourceRecordId = response.entries[0].sourceRecordId
    * def secondSourceRecordId = response.entries[1].sourceRecordId

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def firstRecordPoLineId = response.relatedPoLineInfo.idList[0]
    * def firstRecordOrderId = response.relatedPoLineInfo.orderId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def secondRecordPoLineId = response.relatedPoLineInfo.idList[0]
    And def secondRecordOrderId = response.relatedPoLineInfo.orderId
    And match secondRecordOrderId != firstRecordOrderId
    And match secondRecordPoLineId != firstRecordPoLineId

    # Check mapping result first order
    Given path 'orders/composite-orders', firstRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result first poLine
    Given path 'orders/order-lines', firstRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Pending"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId

    # Check mapping result second order
    Given path 'orders/composite-orders', secondRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result second poLine
    Given path 'orders/order-lines', secondRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Pending"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == secondRecordOrderId

  Scenario: FAT-3047 Test import open order, inventory actions not ignored, override POLines limit
    * def orderStatus = "Open"
    * def uniqueID = "open order"
    * def mrcFile = "FAT-3047"
    * def overridePoLinesLimit = "\"1\""

    * call read('@ImportOrderWithMultipleActions')

    # Verify job execution for create open order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == 'CREATED'
    And match response.entries[0].instanceActionStatus == 'CREATED'
    And match response.entries[0].holdingsActionStatus == 'CREATED'
    And match response.entries[0].itemActionStatus == 'CREATED'
    And match response.entries[0].poLineActionStatus == 'CREATED'

    * def firstSourceRecordId = response.entries[0].sourceRecordId
    * def secondSourceRecordId = response.entries[1].sourceRecordId

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def firstRecordPoLineId = response.relatedPoLineInfo.idList[0]
    And def firstRecordOrderId = response.relatedPoLineInfo.orderId
    And def firstInstanceId = response.relatedInstanceInfo.idList[0]

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def secondRecordPoLineId = response.relatedPoLineInfo.idList[0]
    And def secondRecordOrderId = response.relatedPoLineInfo.orderId
    And def secondInstanceId = response.relatedInstanceInfo.idList[0]
    And match secondRecordOrderId != firstRecordOrderId
    And match secondRecordPoLineId != firstRecordPoLineId

    # Check mapping result first order
    Given path 'orders/composite-orders', firstRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result first poLine
    Given path 'orders/order-lines', firstRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Awaiting Payment"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == firstRecordOrderId
    And match response.instanceId == firstInstanceId

    # Check mapping result second order
    Given path 'orders/composite-orders', secondRecordOrderId
    And headers headersUser
    When method GET
    Then status 200
    And match response.workflowStatus == orderStatus
    And match response.vendor == vendorId

    # Check mapping result second poLine
    Given path 'orders/order-lines', secondRecordPoLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.paymentStatus == "Awaiting Payment"
    And match response.orderFormat == "P/E Mix"
    And match response.purchaseOrderId == secondRecordOrderId
    And match response.instanceId == secondInstanceId