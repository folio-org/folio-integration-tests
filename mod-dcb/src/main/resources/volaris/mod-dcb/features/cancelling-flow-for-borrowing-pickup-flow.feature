Feature: Testing Lending Flow Cancellation

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 5, interval: 1000 }

  Scenario: Cancel DCB Transaction manually
    * def transactionId = '0A0'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'abcd' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + 'abcd)'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after OPEN
    * def transactionId = '0B0'
    * def id1 = 'b9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '01' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToOpenRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '01)'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after AWAITING_PICKUP
    * def transactionId = '0C0'
    * def id1 = 'c9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '02' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '02'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '02'
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '02)'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_OUT
    * def transactionId = '0D0'
    * def id1 = 'd9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '03' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '03'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '03'
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = '03'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 0D0. Transaction already in status: ITEM_CHECKED_OUT: '

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_IN
    * def transactionId = '0E0'
    * def id1 = 'e9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '04' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '04'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '04'
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = '04'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWING-PICKUP'

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '04'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '04'
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 0E0. Transaction already in status: ITEM_CHECKED_IN: '

  Scenario: Cancel DCB Transaction automatically
    * def transactionId = '0F0'
    * def id1 = 'f9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '05' }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '05)'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id
    * def existingRequestHoldingId = $.requests[0].holdingsRecordId
    * def existingRequestInstanceId = $.requests[0].instanceId

    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = extUserId
    * cancelRequestEntityRequest.requesterId = extUserId
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = existingRequestHoldingId
    * cancelRequestEntityRequest.instanceId = existingRequestInstanceId
    * cancelRequestEntityRequest.itemId = id1
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204
    * call pause 5000

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

  #Negative
  Scenario: Cancel DCB Transaction manually after CLOSED
    * def transactionId = '0G0'
    * def id1 = 'e9b73276-77b6-11ee-b962-0252ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrowing-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '06' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def updateToCloseRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-close.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '06'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '06'
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = '06'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWING-PICKUP'

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = '06'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == '06'
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWING-PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCloseRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 0G0. Transaction already in status: CLOSED: '
