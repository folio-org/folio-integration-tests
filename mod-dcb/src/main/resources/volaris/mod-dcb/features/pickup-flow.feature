Feature: Pickup Flow Scenarios

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

  Scenario: Validation. Patron group should be validated at the time of user creation.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId80
    * createDCBTransactionRequest.item.barcode = itemBarcode80
    #
    * createDCBTransactionRequest.patron.id = patronIdNonExisting
    * createDCBTransactionRequest.patron.group = patronNameNonExisting
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation12
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Patron group not found with name '+patronNameNonExisting + ' '
    And match $.errors[0].code == 'NOT_FOUND_ERROR'

  Scenario: Validation. If the item barcode is already present in the inventory, error will be thrown.

    # create item with Barcode itemBarcodeAlreadyExists3
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = intMaterialTypeId3
    * materialTypeEntityRequest.name = intMaterialTypeName3
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    # create item with barcode itemBarcodeAlreadyExists3
    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcodeAlreadyExists3
    * itemEntityRequest.id = itemId7
    * itemEntityRequest.materialType.id = intMaterialTypeId3
    * itemEntityRequest.status.name = 'Available'

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

     # create Transaction with itemBarcodeAlreadyExists3
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId7
    # item with existing barcode itemBarcodeAlreadyExists3
    * createDCBTransactionRequest.item.barcode = itemBarcodeAlreadyExists3
    * createDCBTransactionRequest.patron.id = patronId3
    * createDCBTransactionRequest.patron.barcode = patronBarcode3
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation20
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'Unable to create item with barcode ' + itemBarcodeAlreadyExists3 + ' as it exists in inventory '

  Scenario: Validation. If item is not present in inventory, new virtual item will be created.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId60 and itemBarcode60 will be created automatically
    * createDCBTransactionRequest.item.id = itemId60
    * createDCBTransactionRequest.item.barcode = itemBarcode60
    * createDCBTransactionRequest.patron.id = patronId3
    * createDCBTransactionRequest.patron.barcode = patronBarcode3
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation10
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode60 + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    # Cancel transaction in order to reuse the same item id and item barcode.
    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = patronId3
    * cancelRequestEntityRequest.requesterId = patronId3
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = itemId60
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId21

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , dcbTransactionIdValidation10 , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterCancelled
  Scenario: Get Transaction status list after Cancelled
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionIdValidation10
    And match response.transactions[0].status == 'CANCELLED'

  Scenario: Validation. If virtual item already exists, it will be reused. Make sure same id and barcode should be used. itemId2 reused

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId60 and itemBarcode60 will be created automatically
    * createDCBTransactionRequest.item.id = itemId60
    * createDCBTransactionRequest.item.barcode = itemBarcode60
    * createDCBTransactionRequest.patron.id = patronId3
    * createDCBTransactionRequest.patron.barcode = patronBarcode3
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation11
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Validation. Material type in the request should be present in inventory or else error will be thrown.

    # create item with not existing material type
    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcode70
    * itemEntityRequest.id = itemId70
    # not existing material type
    * itemEntityRequest.materialType.id = intMaterialTypeIdNonExisting
    * itemEntityRequest.status.name = 'Available'

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'Cannot set item.materialtypeid = ' + intMaterialTypeIdNonExisting + ' because it does not exist in material_type.id.'

    # If the material type is not given in the request, then we check for default material type as book in inventory, if it doesn't exist, we throw the error.
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.name = 'book'
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method GET
    Then status 200

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId41
    * createDCBTransactionRequest.item.barcode = itemBarcode41
    * createDCBTransactionRequest.patron.id = patronId41
    * createDCBTransactionRequest.patron.barcode = patronBarcode41
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionId41
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Validation. If the userId and barcode is not exist already, new user with type DCB will be created. If it is a existing user and type is not dcb or shadow, error will be thrown.

    Given path '/users/' + patronId41
    When method GET
    Then status 200
    And match $.barcode == patronBarcode41
    And match $.type == 'dcb'

  Scenario: Validation. If it is a existing user and type is not dcb or shadow, error will be thrown.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId111
    * createDCBTransactionRequest.item.barcode = itemBarcode111
    * createDCBTransactionRequest.patron.id = patronId111
    * createDCBTransactionRequest.patron.barcode = patronBarcode111
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionId61
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 400
    And match $.errors[0].message == 'User with type patron is retrieved. so unable to create transaction'

  Scenario: Get User after creating dcb transaction

    Given path 'users', patronId41
    When method GET
    Then status 200
    And match $.barcode == patronBarcode41

  Scenario: Get Item status after creating dcb transaction

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode41 + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'PICKUP'


  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToOpen
  Scenario: Check Transaction status after updating it to open
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterOpen
  Scenario: Get Transaction status list after Open
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionIdValidation10
    And match response.transactions[0].status == 'CANCELLED'
    And match response.transactions[1].id == dcbTransactionId41
    And match response.transactions[1].status == 'OPEN'

  @CheckIn1
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.itemBarcode = itemBarcode41
    * checkInRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get Item status after manual check in

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'Awaiting pickup'

  @GetTransactionStatusAfterCheckIn1
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterAwaitingPickup
  Scenario: Get Transaction status list after Awaiting pickup
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    When method GET
    Then status 200
    And match $.totalRecords == 3
    And match $.maximumPageNumber == 0
    And match response.transactions[0].id == dcbTransactionIdValidation10
    And match response.transactions[0].status == 'CANCELLED'
    And match response.transactions[1].id == dcbTransactionId41
    And match response.transactions[1].status == 'OPEN'
    And match response.transactions[2].id == dcbTransactionId41
    And match response.transactions[2].status == 'AWAITING_PICKUP'

  @CheckOut
  Scenario: do check out
    * def checkOutByBarcodeId = '3a40852d-49fd-4df2-a1f9-6e2641a6e93g'
    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.itemBarcode = itemBarcode41
    * checkOutByBarcodeEntityRequest.userBarcode = patronBarcode41
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

  Scenario: Get Item status after manual check out

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'Checked out'

  Scenario: Get request by barcode and item ID after manual check out

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode41 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

  Scenario: Get loan by item ID after manual check out

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    * def itemId = $.items[0].id

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId41


  @GetTransactionStatusAfterCheckOut
  Scenario: Check Transaction status after manual check out
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterCheckOut
  Scenario: Get Transaction status list after Check out
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    And param pageSize = 3
    And param pageNumber = 1
    When method GET
    Then status 200
    And match $.totalRecords == 4
    And match $.maximumPageNumber == 1
    And match response.transactions[0].id == dcbTransactionId41
    And match response.transactions[0].status == 'ITEM_CHECKED_OUT'

  @CheckIn2
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.itemBarcode = itemBarcode41
    * checkInRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get loan by item ID after manual check in

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    * def itemId = $.items[0].id

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId41
    And match $.loans[0].status.name == 'Closed'

  Scenario: Get Item status after manual check in 2

    Given path 'circulation-item'
    Given param query = '(barcode= ' +  itemBarcode41 + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

  @GetTransactionStatusAfterCheckIn2
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterCheckIn
  Scenario: Get Transaction status list after Check In
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    And param pageSize = 3
    And param pageNumber = 1
    When method GET
    Then status 200
    And match $.totalRecords == 5
    And match $.maximumPageNumber == 1
    And match response.transactions[0].id == dcbTransactionId41
    And match response.transactions[0].status == 'ITEM_CHECKED_OUT'
    And match response.transactions[1].id == dcbTransactionId41
    And match response.transactions[1].status == 'ITEM_CHECKED_IN'

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToClosedRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToClosed
  Scenario: Check Transaction status after updating it to closed
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId41 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'PICKUP'

  @GetTransactionStatusListAfterClosed
  Scenario: Get Transaction status list after Closed
    * def endDate = call getCurrentUtcDate
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    Given path newPath
    And param apikey = key
    And param fromDate = startDate
    And param toDate = endDate
    And param pageSize = 1
    And param pageNumber = 5
    When method GET
    Then status 200
    And match $.totalRecords == 6
    And match $.maximumPageNumber == 5
    And match response.transactions[0].id == dcbTransactionId41
    And match response.transactions[0].status == 'CLOSED'