Feature: Testing Pickup Flow Cancellation

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 10, interval: 1000 }

  Scenario: Cancel DCB Transaction manually
    * def transactionId = 'A1'
    * def id1 = 'a9b73276-77b6-11ee-b962-1242ac120003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'A1', userId: '#(id1)', barcode: 'A1' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + 'A1' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after OPEN
    * def transactionId = 'B1'
    * def id1 = 'a9b73276-77b7-11ee-b962-1242ac120003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'B1', userId: '#(id1)', barcode: 'B1' }
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
    And match $.role == 'PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + 'B1' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after AWAITING_PICKUP
    * def transactionId = 'C1'
    * def id1 = 'a9b73276-77b8-11ee-b962-1242ac120003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'C1', userId: '#(id1)', barcode: 'C1' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = 'C1'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == 'C1'
    And match $.item.status.name == 'Awaiting pickup'

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    And retry until responseStatus == 200
    And match $.status == 'CANCELLED'
    And match $.role == 'PICKUP'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + 'C1' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_OUT
    * def transactionId = 'D1'
    * def id1 = 'a9b73276-77b8-11ee-b962-1242ac130003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'D1', userId: '#(id1)', barcode: 'D1' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = 'D1'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == 'D1'

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'PICKUP'

    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = 'D1'
    * checkOutByBarcodeEntityRequest.itemBarcode = 'D1'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201


    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'PICKUP'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: D1. Transaction already in status: ITEM_CHECKED_OUT: '

   #Negative
   Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_IN
     * def transactionId = 'E1'
     * def id1 = 'a9b73276-77b8-11ee-b962-1242bc130003'
     * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'E1', userId: '#(id1)', barcode: 'E1' }
     * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

     * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
     * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
     * set checkInRequest.itemBarcode = 'E1'

     Given path 'circulation', 'check-in-by-barcode'
     And request checkInRequest
     When method POST
     Then status 200
     And match $.item.barcode == 'E1'

     Given path 'transactions' , transactionId , 'status'
     When method GET
     Then status 200
     And match $.status == 'AWAITING_PICKUP'
     And match $.role == 'PICKUP'

     * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
     * checkOutByBarcodeEntityRequest.userBarcode = 'E1'
     * checkOutByBarcodeEntityRequest.itemBarcode = 'E1'
     * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
     Given path 'circulation', 'check-out-by-barcode'
     And request checkOutByBarcodeEntityRequest
     When method POST
     Then status 201


     Given path 'transactions' , transactionId , 'status'
     When method GET
     Then status 200
     And match $.status == 'ITEM_CHECKED_OUT'
     And match $.role == 'PICKUP'

     Given path 'circulation', 'check-in-by-barcode'
     And request checkInRequest
     When method POST
     Then status 200
     And match $.item.barcode == 'E1'

     Given path 'transactions' , transactionId , 'status'
     And request updateToCancelRequest
     When method PUT
     Then status 400
     And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: E1. Transaction already in status: ITEM_CHECKED_IN: '

  Scenario: Cancel DCB Transaction automatically
    * def transactionId = 'F1'
    * def id1 = 'a9b73376-77b6-11ee-b962-1242ac120003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'F1', userId: '#(id1)', barcode: 'F1' }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + 'F1' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = id1
    * cancelRequestEntityRequest.requesterId = id1
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = id1
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'PICKUP'

  #Negative
  Scenario: Cancel DCB Transaction manually after CLOSED
    * def transactionId = 'G1'
    * def id1 = 'a9b73276-77b8-11ee-b962-2242bc130003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-pickup.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: 'G1', userId: '#(id1)', barcode: 'G1' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')
    * def updateToCloseRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-close.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = 'G1'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == 'G1'

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'PICKUP'

    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = 'G1'
    * checkOutByBarcodeEntityRequest.itemBarcode = 'G1'
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201


    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'PICKUP'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == 'G1'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCloseRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: G1. Transaction already in status: CLOSED: '

