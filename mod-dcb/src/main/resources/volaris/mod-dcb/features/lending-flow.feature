Feature: Testing Lending Flow

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce read('classpath:volaris/mod-dcb/global/variables.feature')
    * def startDate = callonce getCurrentUtcDate

  Scenario: Validation. Item needs to be present in inventory.(Real item)

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemIdNotExisting
    * def orgPath = '/transactions/' + dcbTransactionId511
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Unable to find existing item with id ' + itemIdNotExisting + ' and barcode ' + itemBarcode + '.'
    And match $.errors[0].code == 'NOT_FOUND_ERROR'

  Scenario: Validation. Patron group should be validated at the time of user creation.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.patron.id = patronIdNonExisting
    * createDCBTransactionRequest.patron.group = patronNameNonExisting
    * def orgPath = '/transactions/' + dcbTransactionId611
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
    * createDCBTransactionRequest.item.id = itemId11
    * createDCBTransactionRequest.item.barcode = itemBarcode11
    * createDCBTransactionRequest.patron.id = patronId11
    * createDCBTransactionRequest.patron.barcode = patronBarcode11
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21

    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId11
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId11
    And match $.patron.id == patronId11

  Scenario: Validation. TransactionId should be unique for every transaction or else it will throw error.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId11
    * createDCBTransactionRequest.item.barcode = itemBarcode11
    * createDCBTransactionRequest.patron.id = patronId11
    * createDCBTransactionRequest.patron.barcode = patronBarcode11
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21

    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId11
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'unable to create transaction with id '+ dcbTransactionId11 +' as it already exists'
    And match $.errors[0].code == 'DUPLICATE_ERROR'

  Scenario: Get Item status after creating dcb transaction

    Given path 'item-storage', 'items', itemId11
    When method GET
    Then status 200
    And match $.barcode == itemBarcode11
    And match $.status.name == 'Paged'


  Scenario: Get User Type  after creating dcb transaction. Validation. If the userId and barcode is not exist already, new user with type DCB will be created

    Given path '/users/' + patronId11
    When method GET
    Then status 200
    And match $.barcode == patronBarcode11
    And match $.type == 'dcb'

  Scenario: Validation. If it is a existing user and type is not dcb or shadow, error will be thrown.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId110
    * createDCBTransactionRequest.item.barcode = itemBarcode110
    * createDCBTransactionRequest.patron.id = patronId110
    * createDCBTransactionRequest.patron.barcode = patronBarcode110
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21

    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId51
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 400
    And match $.errors[0].message == 'User with type patron is retrieved. so unable to create transaction'

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode11 + ' and itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  Scenario: Get loan by item ID after creating dcb transaction

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
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
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode11
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode11
    And match $.item.status.name == 'In transit'
    * call pause 5000

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
    Given param query = '(item.barcode= ' + itemBarcode11 + ' and itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - In transit'


  Scenario: Get loan by item ID after manual check in

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  @GetTransactionStatusAfterCheckIn1
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

  @GetTransactionStatusListAfterOpen
  Scenario: Get Transaction status list after Open
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = proxyCall == true ? proxyStartDate : startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionId11
    And match response.transactions[0].status == 'OPEN'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    * call pause 5000

  Scenario: Get request by barcode and item ID after updating it to AWAITING_PICKUP

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode11 + ' and itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Awaiting pickup'

  Scenario: Get loan by item ID after updating it to AWAITING_PICKUP

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Get Item status after updating it to AWAITING_PICKUP

    Given path 'item-storage', 'items', itemId11
    When method GET
    Then status 200
    And match $.barcode == itemBarcode11
    And match $.status.name == 'Awaiting pickup'

  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

  @GetTransactionStatusListAfterAwaitingPickup
  Scenario: Get Transaction status list after Awaiting pickup
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = proxyCall == true ? proxyStartDate : startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionId11
    And match response.transactions[1].id == dcbTransactionId11
    And match response.transactions[0].status == 'OPEN'
    And match response.transactions[1].status == 'AWAITING_PICKUP'

  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT
    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToCheckOutRequest
    When method PUT
    Then status 200

  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT. Second time the same status.
    * def updateToCheckOutRequest = read('samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path 'transactions' , dcbTransactionId11 , 'status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Current transaction status equal to new transaction status: dcbTransactionId: 1234, status: ITEM_CHECKED_OUT'
    And match $.errors[0].code == 'VALIDATION_ERROR'

  Scenario: Get request by barcode and item ID after updating it to ITEM_CHECKED_OUT

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode11 + ' and itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Filled'
    And match $.totalRecords == 1

  Scenario: Get loan by item ID after updating it to ITEM_CHECKED_OUT

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId11 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId11


  Scenario: Get Item status after updating it to ITEM_CHECKED_OUT

    Given path 'item-storage', 'items', itemId11
    When method GET
    Then status 200
    And match $.barcode == itemBarcode11
    And match $.status.name == 'Checked out'

  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'

  @GetTransactionStatusListAfterItemCheckedOut
  Scenario: Get Transaction status list after Item checked out
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = proxyCall == true ? proxyStartDate : startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 3
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionId11
    And match response.transactions[1].id == dcbTransactionId11
    And match response.transactions[2].id == dcbTransactionId11
    And match response.transactions[0].status == 'OPEN'
    And match response.transactions[1].status == 'AWAITING_PICKUP'
    And match response.transactions[2].status == 'ITEM_CHECKED_OUT'

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN
    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'LENDER'

  @GetTransactionStatusListAfterItemCheckedIn
  Scenario: Get Transaction status list after Item checked in
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = proxyCall == true ? proxyStartDate : startDate
    And param toDate = endDate
    And param pageSize = 3
    And param pageNumber = 1
    When method GET
    Then status 200
    And match $.totalRecords == 4
    And match $.maximumPageNumber == 1
    And match response.transactions[0].id == dcbTransactionId11
    And match response.transactions[0].status == 'ITEM_CHECKED_IN'

  Scenario: Get Item status after updating it to ITEM_CHECKED_IN

    Given path 'item-storage', 'items', itemId11
    When method GET
    Then status 200
    And match $.barcode == itemBarcode11
    And match $.status.name == 'Checked out'

  @CheckIn2
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode11

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode11
#    And match $.item.status.name == 'Available'
    * call pause 5000

  @GetTransactionStatusAfterCheckIn2
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId11 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'LENDER'

  @GetTransactionStatusListAfterClosed
  Scenario: Get Transaction status list after Closed
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = proxyCall == true ? proxyStartDate : startDate
    And param toDate = endDate
    And param pageSize = 2
    And param pageNumber = 1
    When method GET
    Then status 200
    And match $.totalRecords == 5
    And match $.maximumPageNumber == 2
    And match response.transactions[0].id == dcbTransactionId11
    And match response.transactions[1].id == dcbTransactionId11
    And match response.transactions[0].status == 'ITEM_CHECKED_OUT'
    And match response.transactions[1].status == 'ITEM_CHECKED_IN'
