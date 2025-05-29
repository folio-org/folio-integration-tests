Feature: Test Data-Import holdings records

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def defaultPoLineLimit = 2
    * def vendorId = "c6dace5d-4574-411e-8ba1-036102fcdc9b"


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

    * call read('this:helpers/data-import-orders-utils.feature@ImportOrderWithNoOtherAction') { p_uniqueID: '#(uniqueID)', p_orderStatus: '#(orderStatus)', p_mrcFile: '#(mrcFile)' }

    # Verify job execution for create pending order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedPoLineInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedPoLineInfo.actionStatus == "CREATED"
    And match response.entries[1].relatedPoLineInfo.actionStatus == "CREATED"
    * def firstSourceRecordId = response.entries[0].incomingRecordId
    * def secondSourceRecordId = response.entries[1].incomingRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    And retry until karate.get('response.relatedPoLineInfo.idList.length') > 0
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

    * call read('this:helpers/data-import-orders-utils.feature@ImportOrderWithNoOtherAction') { p_uniqueID: '#(uniqueID)', p_orderStatus: '#(orderStatus)', p_mrcFile: '#(mrcFile)' }

    # Verify job execution for create open order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedPoLineInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedPoLineInfo.actionStatus == "CREATED"
    And match response.entries[1].relatedPoLineInfo.actionStatus == "CREATED"
    * def firstSourceRecordId = response.entries[0].incomingRecordId
    * def secondSourceRecordId = response.entries[1].incomingRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    And retry until karate.get('response.relatedPoLineInfo.idList.length') > 0
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

    * call read('this:helpers/data-import-orders-utils.feature@ImportOrderWithMultipleActions') { p_uniqueID: '#(uniqueID)', p_orderStatus: '#(orderStatus)', p_mrcFile: '#(mrcFile)' }

    # Verify job execution for create pending order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedPoLineInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == '#notpresent'
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == '#notpresent'
    And match response.entries[0].relatedItemInfo[0].actionStatus == '#notpresent'
    And match response.entries[0].relatedPoLineInfo.actionStatus == 'CREATED'

    * def firstSourceRecordId = response.entries[0].incomingRecordId
    * def secondSourceRecordId = response.entries[1].incomingRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    And retry until karate.get('response.relatedPoLineInfo.idList.length') > 0
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

    * call read('this:helpers/data-import-orders-utils.feature@ImportOrderWithMultipleActions') { p_uniqueID: '#(uniqueID)', p_orderStatus: '#(orderStatus)', p_mrcFile: '#(mrcFile)' }

    # Verify job execution for create open order
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedItemInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedPoLineInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == 'CREATED'
    And match response.entries[0].relatedItemInfo[0].actionStatus == 'CREATED'
    And match response.entries[0].relatedPoLineInfo.actionStatus == 'CREATED'

    * def firstSourceRecordId = response.entries[0].incomingRecordId
    * def secondSourceRecordId = response.entries[1].incomingRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', firstSourceRecordId
    And headers headersUser
    And retry until karate.get('response.relatedPoLineInfo.idList.length') > 0
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
