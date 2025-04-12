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
    * def transactionId = '010'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId1)', itemBarcode: '#(itemBarcode1)' }
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
    And match $.role == 'LENDER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode1 + ' and itemId = ' + extItemId1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction automatically
    * def transactionId = '00'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId5)', itemBarcode: '#(itemBarcode5)' }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode5 + ' and itemId = ' + extItemId5 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = patronId
    * cancelRequestEntityRequest.requesterId = patronId
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = extItemId5
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'LENDER'

  Scenario: Cancel DCB Transaction manually after OPEN
    * def transactionId = '020'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId5)', itemBarcode: '#(itemBarcode5)' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = itemBarcode5

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode5
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'LENDER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode5 + ' and itemId = ' + extItemId5 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after AWAITING_PICKUP

    * def transactionId = '030'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId2)', itemBarcode: '#(itemBarcode2)' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = itemBarcode2

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode2
    And match $.item.status.name == 'In transit'

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    And retry until response.status == 'CANCELLED'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'LENDER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode2 + ' and itemId = ' + extItemId2 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_OUT
    * def transactionId = '040'
    * def itemId = 'c7a2f4de-77af-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId3)', itemBarcode: '#(itemBarcode3)' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = itemBarcode3


    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode3
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 040. Transaction already in status: ITEM_CHECKED_OUT: '

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_IN
    * def transactionId = '050'
    * def itemId = 'c7a2f4de-78af-11ee-b962-0242ac120002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(extItemId4)', itemBarcode: '#(itemBarcode4)' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * set checkInRequest.itemBarcode = itemBarcode4


    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode4
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode4
    And match $.item.status.name == 'Available'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 050. Transaction already in status: CLOSED: '
