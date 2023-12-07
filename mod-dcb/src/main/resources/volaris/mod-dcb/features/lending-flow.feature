Feature: Testing Lending Flow

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? admin : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables

  Scenario: call pre requisites feature file
    Given call read('classpath:volaris/mod-dcb/reusable/pre-requisites.feature')

  Scenario: Validation. Item needs to be present in inventory.(Real item)

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-with-not-existing-item.json')
    * def orgPath = '/transactions/' + dcbTransactionIdNonExistingItem
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Item not found for itemId ' + notExistingItem+ ' '
    And match $.errors[0].code == 'NOT_FOUND_ERROR'

  Scenario: Validation. Patron group should be validated at the time of user creation.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-with-not-existing-patron.json')
    * def orgPath = '/transactions/' + dcbTransactionIdNonExistingPatron
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Patron group not found with name '+patronNameNonExisting + ' '
    And match $.errors[0].code == 'NOT_FOUND_ERROR'

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * def orgPath = '/transactions/' + dcbTransactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == extItemId
    And match $.patron.id == patronId

  Scenario: Validation. TransactionId should be unique for every transaction or else it will throw error.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * def orgPath = '/transactions/' + dcbTransactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'unable to create transaction with id '+ dcbTransactionId +' as it already exists'
    And match $.errors[0].code == 'DUPLICATE_ERROR'

  Scenario: Get Item status after creating dcb transaction

    Given path 'item-storage', 'items', extItemId
    When method GET
    Then status 200
    And match $.barcode == itemBarcode
    And match $.status.name == 'Paged'

  Scenario: Get User Type  after creating dcb transaction. Validation. If the userId and barcode is not exist already, new user with type DCB will be created.
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

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
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

  @CheckIn1
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'In transit'

  Scenario: current item check-in with non-existing barcode item
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-non-existing-barcode-entity-request.json')

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest2
    When method POST
    Then status 422
    And match $.errors[0].message == 'No item with barcode ' + itemNonExistingBarcode + ' exists'


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

  @GetTransactionStatusAfterCheckIn1
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
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

  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT
    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
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

  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN
    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToCheckInRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToItemCheckedIn
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_IN
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
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

  @CheckIn2
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'Available'

  @GetTransactionStatusAfterCheckIn2
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'LENDER'

