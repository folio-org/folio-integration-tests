Feature: Borrower Update Status Restriction

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables
    * def startDate = callonce getCurrentUtcDate
    * configure retry = { count: 5, interval: 1000 }

  @C627525
  Scenario: Verify transaction details update is blocked from non-CREATED statuses

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    * def txnId = '627525'
    * def txnItemId = 'c627525a-0000-4000-8000-000000000001'
    * def itemBarcode627 = 'FAT-627525-bc'
    * def newBarcode = 'FAT-627525-bc-upd'

    * def orgPathTxn = '/transactions/' + txnId
    * def newPathTxn = proxyCall == true ? proxyPath + orgPathTxn : orgPathTxn
    * def newPathTxnStatus = newPathTxn + '/status'

    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = txnItemId
    * createReq.item.barcode = itemBarcode627
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.pickup.servicePointId = servicePointId
    * createReq.pickup.servicePointName = servicePointName
    * createReq.pickup.libraryCode = 'test-lib'
    * createReq.role = 'BORROWER'

    Given path newPathTxn
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcode627
    And match $.patron.id == patronId31

    * def updateReq = { item: { barcode: '#(newBarcode)', materialType: '#(materialTypeName)', lendingLibraryCode: 'NEW-LIB' } }

    Given path newPathTxnStatus
    And param apikey = key
    And request { status: 'OPEN' }
    When method PUT
    Then status 200

    Given path newPathTxn
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Transaction details should not be updated from OPEN status, it can be updated only from CREATED status'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    Given path newPathTxnStatus
    And param apikey = key
    And request { status: 'AWAITING_PICKUP' }
    When method PUT
    Then status 200

    Given path newPathTxn
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Transaction details should not be updated from AWAITING_PICKUP status, it can be updated only from CREATED status'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    Given path newPathTxnStatus
    And param apikey = key
    And request { status: 'ITEM_CHECKED_OUT' }
    When method PUT
    Then status 200

    Given path newPathTxn
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Transaction details should not be updated from ITEM_CHECKED_OUT status, it can be updated only from CREATED status'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    Given path newPathTxnStatus
    And param apikey = key
    And request { status: 'ITEM_CHECKED_IN' }
    When method PUT
    Then status 200

    Given path newPathTxn
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Transaction details should not be updated from ITEM_CHECKED_IN status, it can be updated only from CREATED status'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    Given path newPathTxnStatus
    And param apikey = key
    And request { status: 'CLOSED' }
    When method PUT
    Then status 200

    Given path newPathTxn
    And param apikey = key
    And request updateReq
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Transaction details should not be updated from CLOSED status, it can be updated only from CREATED status'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    * def orgPathStatus = '/transactions/status'
    * def newPathStatus = proxyCall == true ? proxyPath + orgPathStatus : orgPathStatus
    * def pollConfig = { expectedRecords: 5, path: '#(newPathStatus)', apikey: '#(key)', baseUrl: '#(baseUrlNew)', startDate: '#(startDate)' }

    Given def pollResult = call read("classpath:volaris/mod-dcb/reusable/poll-transaction-statuses.feature@PollTransactionStatuses") { config: '#(pollConfig)' }
    Then def txnStatusResponse = pollResult.response
    And match txnStatusResponse.totalRecords == 5
    And match txnStatusResponse.transactions[*].status contains only ['OPEN', 'AWAITING_PICKUP', 'ITEM_CHECKED_OUT', 'ITEM_CHECKED_IN', 'CLOSED']
    And match each txnStatusResponse.transactions[*].id == txnId
    And match each txnStatusResponse.transactions[*].item.barcode == itemBarcode627
