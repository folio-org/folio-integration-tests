Feature: Testing Borrowing-Pickup Flow

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * callonce variables
    * def startDate = callonce getCurrentUtcDate
    * configure retry = { count: 5, interval: 1000 }
    * def bpTransactionId1 = call uuid1
    * def bpTransactionId2 = call uuid1
    * def bpTransactionId3 = call uuid1
    * def bpItemId1 = call uuid1
    * def bpItemBarcode1 = call random_string
    * def bpItemId2 = call uuid1
    * def bpItemBarcode2 = call random_string

  Scenario: Validation. If the userId and barcode is not exist already, error will be thrown.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId20
    * createDCBTransactionRequest.item.barcode = itemBarcode20
    # not existing patron id patronIdNonExisting
    * createDCBTransactionRequest.patron.id = patronIdNonExisting
    # not existing patron barcode patronBarcodeNonExisting
    * createDCBTransactionRequest.patron.barcode = patronBarcodeNonExisting
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation1
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Unable to find existing user with barcode '+ patronBarcodeNonExisting + ' and id ' + patronIdNonExisting + '.'

  Scenario: Validation. If the item barcode is already present in the inventory, error will be thrown.
    * def holdingId = call uuid1
    * print 'holdingId is'
    * print holdingId
    Given call read(utilsPath+'@PostHoldings') {extHoldingsRecordId: #(holdingId)}

    * def materialTypeId = call uuid1
    * def materialTypeName = call random_string
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = materialTypeId
    * materialTypeEntityRequest.name = materialTypeName
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    # create item with barcode itemBarcodeAlreadyExists
    * def itemId = call uuid1
    * def itemBarcode = call random_string
    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcode
    * itemEntityRequest.id = itemId
    * itemEntityRequest.holdingsRecordId = holdingId
    * itemEntityRequest.materialType.id = materialTypeId
    * itemEntityRequest.materialType.name = materialTypeName
    * itemEntityRequest.status.name = 'Available'

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

     # create Transaction with itemBarcodeAlreadyExists
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId
    # item with existing barcode itemBarcodeAlreadyExists
    * createDCBTransactionRequest.item.barcode = itemBarcode
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def transactionId = call uuid1
    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'Unable to create item with barcode ' + itemBarcode + ' as it exists in inventory '

  Scenario: Validation. If item is not present in inventory, new virtual item will be created.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId30 and itemBarcode30 will be created automatically
    * createDCBTransactionRequest.item.id = bpItemId1
    * createDCBTransactionRequest.item.barcode = bpItemBarcode1
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + bpTransactionId1
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + bpItemBarcode1 + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id
    * def existingRequestHoldingId = $.requests[0].holdingsRecordId
    * def existingRequestInstanceId = $.requests[0].instanceId

    # Cancel transaction in order to reuse the same item id and item barcode.
    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = patronId1
    * cancelRequestEntityRequest.requesterId = patronId1
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = existingRequestHoldingId
    * cancelRequestEntityRequest.instanceId = existingRequestInstanceId
    * cancelRequestEntityRequest.itemId = bpItemId1
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId21

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , bpTransactionId1 , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

  Scenario: Validation. If virtual item already exists, it will be reused. Make sure same id and barcode should be used. itemId30 reused

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')

    * createDCBTransactionRequest.item.id = bpItemId1
    * createDCBTransactionRequest.item.barcode = bpItemBarcode1
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + bpTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    And retry until responseStatus == 201
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Validation. If the user exist but the type is DCB, error will be thrown

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = bpItemId1
    * createDCBTransactionRequest.item.barcode = bpItemBarcode1
    * createDCBTransactionRequest.patron.id = patronId51
    * createDCBTransactionRequest.patron.barcode = patronBarcode51
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def transactionId = call uuid1

    * def orgPath = '/transactions/' + transactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 400
    And match $.errors[0].message == 'User with type dcb is retrieved. so unable to create transaction'

  @PerformDCBStatusTransitionForBorrowingPickupRole
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * def orgPath = '/transactions/' + bpTransactionId3
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    * createDCBTransactionRequest.item.id = bpItemId2
    * createDCBTransactionRequest.item.barcode = bpItemBarcode2
    * createDCBTransactionRequest.patron.id = patronId21
    * createDCBTransactionRequest.patron.barcode = patronBarcode21
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    * print 'Get Item status after creating dcb transaction'
    * url baseUrl
    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

    * print 'Get request by barcode and item ID after creating dcb transaction'
    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

    * print 'Check Transaction status after creating dcb transaction'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'BORROWING-PICKUP'

    * print 'Update DCB transaction status to Open'
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    * print 'Check Transaction status after updating it to open'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWING-PICKUP'

    * print 'call item check-in manually'
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = bpItemBarcode2

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

    * print 'Get Item status after manual check in'

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'Awaiting pickup'

    * print 'Check Transaction status after manual check in'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    * print 'do check out'
    * url baseUrl
    * def checkOutByBarcodeId = call uuid1
    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.itemBarcode = bpItemBarcode2
    * checkOutByBarcodeEntityRequest.userBarcode = patronBarcode21
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

    * print 'Get Item status after manual check out'

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'Checked out'

    * print 'Get request by barcode and item ID after manual check out'
    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    * def itemId = $.items[0].id

    * print 'Get loan by item ID after manual check out'
    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId21

    * print 'Check Transaction status after manual check out'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWING-PICKUP'

    * print 'current item check-in record and its status'
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = bpItemBarcode2

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

    * print 'Get loan by item ID after manual check in'

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    * def itemId = $.items[0].id

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId21
    And match $.loans[0].status.name == 'Closed'

    * print 'Get Item status after manual check in 2'

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  bpItemBarcode2 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

    * print 'Check Transaction status after manual check in'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWING-PICKUP'

    * print 'Update DCB transaction status to closed.'
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToClosedRequest
    When method PUT
    Then status 200

    * print 'Check Transaction status after updating it to closed'
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + bpTransactionId3 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWING-PICKUP'