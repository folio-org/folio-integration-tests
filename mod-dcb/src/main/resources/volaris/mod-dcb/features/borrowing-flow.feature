Feature: Borrowing Flow Scenarios

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
    * callonce variables
    * def startDate = callonce getCurrentUtcDate

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
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId1
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation1
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Unable to find existing user with barcode '+ patronBarcodeNonExisting + ' and id ' + patronIdNonExisting + '.'

  Scenario: Validation. If the item barcode is already present in the inventory, error will be thrown.

    # create item with Barcode itemBarcodeAlreadyExists2
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = intMaterialTypeId1
    * materialTypeEntityRequest.name = intMaterialTypeName1
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    # create item with barcode itemBarcodeAlreadyExists
    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcodeAlreadyExists2
    * itemEntityRequest.id = itemId6
    * itemEntityRequest.materialType.id = intMaterialTypeId1
    * itemEntityRequest.status.name = 'Available'

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

     # create Transaction with itemBarcodeAlreadyExists2
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId6
    # item with existing barcode itemBarcodeAlreadyExists2
    * createDCBTransactionRequest.item.barcode = itemBarcodeAlreadyExists2
    * createDCBTransactionRequest.patron.id = patronId2
    * createDCBTransactionRequest.patron.barcode = patronBarcode2
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId1
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'Unable to create item with barcode ' + itemBarcodeAlreadyExists2 + ' as it exists in inventory '

  Scenario: Validation. If item is not present in inventory, new virtual item will be created.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId40 and itemBarcode40 will be created automatically
    * createDCBTransactionRequest.item.id = itemId40
    * createDCBTransactionRequest.item.barcode = itemBarcode40
    * createDCBTransactionRequest.patron.id = patronId2
    * createDCBTransactionRequest.patron.barcode = patronBarcode2
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId1
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation8
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode40 + ' and itemId = ' + itemId40 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    # Cancel transaction in order to reuse the same item id and item barcode.
    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = patronId2
    * cancelRequestEntityRequest.requesterId = patronId2
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = itemId40
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId1

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , dcbTransactionIdValidation8 , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWER'

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
    And match response.transactions[0].id == dcbTransactionIdValidation8
    And match response.transactions[0].status == 'CANCELLED'

  Scenario: Validation. If virtual item already exists, it will be reused. Make sure same id and barcode should be used. itemId2 reused

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId40 and itemBarcode40 will be created automatically
    * createDCBTransactionRequest.item.id = itemId40
    * createDCBTransactionRequest.item.barcode = itemBarcode40
    * createDCBTransactionRequest.patron.id = patronId2
    * createDCBTransactionRequest.patron.barcode = patronBarcode2
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId1
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation9
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
    * itemEntityRequest.barcode = itemBarcode50
    * itemEntityRequest.id = itemId50
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

  Scenario: Validation. If the user exist but the type is DCB, error will be thrown

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId311
    * createDCBTransactionRequest.item.barcode = itemBarcode311
    * createDCBTransactionRequest.patron.id = patronId51
    * createDCBTransactionRequest.patron.barcode = patronBarcode51
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId311
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 400
    And match $.errors[0].message == 'User with type dcb is retrieved. so unable to create transaction'

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId31
    * createDCBTransactionRequest.item.barcode = itemBarcode31
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId31
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Get Item status after creating dcb transaction

    Given path 'circulation-item', itemId31
    When method GET
    Then status 200
    And match $.barcode == itemBarcode31
    And match $.status.name == 'In transit'

  Scenario: Get Service point

    Given path 'service-points', servicePointId21
    When method GET
    Then status 200
    And match $.id == servicePointId21

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode31 + ' and itemId = ' + itemId31 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'BORROWER'


  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWER'

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
    And match response.transactions[0].id == dcbTransactionIdValidation8
    And match response.transactions[0].status == 'CANCELLED'
    And match response.transactions[1].id == dcbTransactionId31
    And match response.transactions[1].status == 'OPEN'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  Scenario: Get Item status after updating it to awaiting pickup

    Given path 'circulation-item', itemId31
    When method GET
    Then status 200
    And match $.barcode == itemBarcode31
    And match $.status.name == 'Awaiting pickup'


  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'

  @GetTransactionStatusListAfterAwaitingPickup
  Scenario: Get Transaction status list after awaiting pickup
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
    And match response.transactions[0].id == dcbTransactionIdValidation8
    And match response.transactions[0].status == 'CANCELLED'
    And match response.transactions[1].id == dcbTransactionId31
    And match response.transactions[1].status == 'OPEN'
    And match response.transactions[2].id == dcbTransactionId31
    And match response.transactions[2].status == 'AWAITING_PICKUP'

  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT.
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200

  Scenario: Get Item status after updating it to ITEM_CHECKED_OUT

    Given path 'circulation-item', itemId31
    When method GET
    Then status 200
    And match $.barcode == itemBarcode31
    And match $.status.name == 'Checked out'


  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWER'

  @GetTransactionStatusListAfterItemCheckOut
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
    And match response.transactions[0].id == dcbTransactionId31
    And match response.transactions[0].status == 'ITEM_CHECKED_OUT'

  Scenario: Get request by barcode and item ID after updating it to ITEM_CHECKED_OUT

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode31 + ' and itemId = ' + itemId31 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

  Scenario: Get loan by item ID after updating it to ITEM_CHECKED_OUT

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId31 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId31

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN.
    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200

  Scenario: Get loan by item ID after updating to ITEM_CHECKED_IN

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId31 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId31

  Scenario: Get Item status after updating it to ITEM_CHECKED_IN

    Given path 'circulation-item', itemId31
    When method GET
    Then status 200
    And match $.barcode == itemBarcode31
    And match $.status.name == 'In transit'


  @GetTransactionStatusAfterUpdatingToItemCheckedIn
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_IN
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWER'

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
    And match response.transactions[0].id == dcbTransactionId31
    And match response.transactions[0].status == 'ITEM_CHECKED_OUT'
    And match response.transactions[1].id == dcbTransactionId31
    And match response.transactions[1].status == 'ITEM_CHECKED_IN'

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId31 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWER'

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
    And match response.transactions[0].id == dcbTransactionId31
    And match response.transactions[0].status == 'CLOSED'