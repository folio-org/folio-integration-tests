Feature: Testing Borrower Flow Cancellation

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser
    * callonce variables

  Scenario: Cancel DCB Transaction manually
    * def transactionId = '100'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '1X' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '1X' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after OPEN
    * def transactionId = '200'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120004'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '2X' }
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
    And match $.role == 'BORROWER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '2X' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  Scenario: Cancel DCB Transaction manually after AWAITING_PICKUP
    * def transactionId = '300'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120005'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '3X' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')


    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '3X' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Cancelled'

  #Negative
  Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_OUT
    * def transactionId = '400'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120006'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '4X' }
    * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'

    * def updateToItemCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , transactionId , 'status'
    And request updateToItemCheckedOutRequest
    When method PUT
    Then status 200

    Given path 'transactions' , transactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWER'

    Given path 'transactions' , transactionId , 'status'
    And request updateToCancelRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 400. Transaction already in status: ITEM_CHECKED_OUT: '

   Scenario: Cancel DCB Transaction manually after ITEM_CHECKED_IN
     * def transactionId = '500'
     * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120007'
     * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '5X' }
     * def updateToCancelRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-cancel.json')

     * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

     Given path 'transactions' , transactionId , 'status'
     And request updateToAwaitingPickupRequest
     When method PUT
     Then status 200

     Given path 'transactions' , transactionId , 'status'
     When method GET
     Then status 200
     And match $.status == 'AWAITING_PICKUP'
     And match $.role == 'BORROWER'

     * def updateToItemCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

     Given path 'transactions' , transactionId , 'status'
     And request updateToItemCheckedOutRequest
     When method PUT
     Then status 200

     Given path 'transactions' , transactionId , 'status'
     When method GET
     Then status 200
     And match $.status == 'ITEM_CHECKED_OUT'
     And match $.role == 'BORROWER'

     * def updateToItemCheckedInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

     Given path 'transactions' , transactionId , 'status'
     And request updateToItemCheckedInRequest
     When method PUT
     Then status 200

     Given path 'transactions' , transactionId , 'status'
     When method GET
     Then status 200
     And match $.status == 'ITEM_CHECKED_IN'
     And match $.role == 'BORROWER'

     Given path 'transactions' , transactionId , 'status'
     And request updateToCancelRequest
     When method PUT
     Then status 400
     And match $.errors[0].message == 'Cannot cancel transaction dcbTransactionId: 500. Transaction already in status: ITEM_CHECKED_IN: '

  Scenario: Cancel DCB Transaction automatically
    * def transactionId = '600'
    * def id1 = 'a9b73276-77b6-11ee-b962-0242ac120008'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '6X' }
    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + '6X' + ' and itemId = ' + id1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = extUserId
    * cancelRequestEntityRequest.requesterId = extUserId
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
    And match $.role == 'BORROWER'



