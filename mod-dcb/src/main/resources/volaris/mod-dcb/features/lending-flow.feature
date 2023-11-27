Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * configure headers = headersUser
    * callonce variables

  Scenario: call pre requisites feature file
    Given call read('classpath:volaris/mod-dcb/reusable/pre-requisites.feature')

  Scenario: Create DCB Transaction
    * def transaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')

    Given path 'transactions' , dcbTransactionId
    And request transaction
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == extItemId
    And match $.patron.id == patronId

  Scenario: Get Item status after creating dcb transaction

    Given path 'item-storage', 'items', extItemId
    When method GET
    Then status 200
    And match $.barcode == itemBarcode
    And match $.status.name == 'Paged'


  Scenario: Get User Type  after creating dcb transaction

    Given path '/users/' + patronId
    When method GET
    Then status 200
    And match $.barcode == patronBarcode
    And match $.type == 'dcb'

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode + ' and itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  Scenario: Get loan by item ID after creating dcb transaction

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Check Transaction status after creating dcb transaction

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'LENDER'

  Scenario: Check Transaction status after creating non-existing dcb transaction status.

    Given path 'transactions' , dcbTransactionIdNonExisting , 'status'
    When method GET
    Then status 404
    And match $.errors[0].message == 'DCB Transaction was not found by id= 123 '
    And match $.errors[0].code == 'NOT_FOUND_ERROR'

  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'In transit'

  Scenario: Get request by barcode and item ID after manual check in

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode + ' and itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - In transit'


  Scenario: Get loan by item ID after manual check in

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Check Transaction status after manual check in

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path 'transactions' , dcbTransactionId , 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  Scenario: Get request by barcode and item ID after updating it to AWAITING_PICKUP

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode + ' and itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Awaiting pickup'

  Scenario: Get loan by item ID after updating it to AWAITING_PICKUP

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Get Item status after updating it to AWAITING_PICKUP

    Given path 'item-storage', 'items', extItemId
    When method GET
    Then status 200
    And match $.barcode == itemBarcode
    And match $.status.name == 'Awaiting pickup'

  Scenario: Check Transaction status after updating it to AWAITING_PICKUP

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT
    * def updateToCheckOutRequest = read('samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , dcbTransactionId , 'status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 200

  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT. Second time the same status.
    * def updateToCheckOutRequest = read('samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , dcbTransactionId , 'status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Current transaction status equal to new transaction status: dcbTransactionId: 123456891, status: ITEM_CHECKED_OUT'
    And match $.errors[0].code == 'VALIDATION_ERROR'

  Scenario: Get request by barcode and item ID after updating it to ITEM_CHECKED_OUT

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode + ' and itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Filled'
    And match $.totalRecords == 1

  Scenario: Get loan by item ID after updating it to ITEM_CHECKED_OUT

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + extItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId


  Scenario: Get Item status after updating it to ITEM_CHECKED_OUT

    Given path 'item-storage', 'items', extItemId
    When method GET
    Then status 200
    And match $.barcode == itemBarcode
    And match $.status.name == 'Checked out'


  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'


  Scenario: Update DCB transaction status to ITEM_CHECKED_IN
    * def updateToCheckInRequest = read('samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path 'transactions' , dcbTransactionId , 'status'
    And request updateToCheckInRequest
    When method PUT
    Then status 200

  Scenario: Check Transaction status after updating it to ITEM_CHECKED_IN

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'LENDER'

  Scenario: Get Item status after updating it to ITEM_CHECKED_IN

    Given path 'item-storage', 'items', extItemId
    When method GET
    Then status 200
    And match $.barcode == itemBarcode
    And match $.status.name == 'Checked out'

  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'Available'


  Scenario: Check Transaction status after manual check in

    Given path 'transactions' , dcbTransactionId , 'status'
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'LENDER'


