Feature: Testing Borrowing-Pickup Flow

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

    Given call read(utilsPath+'@PostHoldings') {holdingId: '70cf22e6-789f-11ee-b962-0242ac120003'}
    # create item with Barcode itemBarcodeAlreadyExists
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = intMaterialTypeId2
    * materialTypeEntityRequest.name = intMaterialTypeName2
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    # create item with barcode itemBarcodeAlreadyExists
    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcodeAlreadyExists
    * itemEntityRequest.id = itemId8
    * itemEntityRequest.holdingsRecordId = '70cf22e6-789f-11ee-b962-0242ac120003'
    * itemEntityRequest.materialType.id = intMaterialTypeId2
    * itemEntityRequest.materialType.name = intMaterialTypeName2
    * itemEntityRequest.status.name = 'Available'

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

     # create Transaction with itemBarcodeAlreadyExists
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId8
    # item with existing barcode itemBarcodeAlreadyExists
    * createDCBTransactionRequest.item.barcode = itemBarcodeAlreadyExists
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 409
    And match $.errors[0].message == 'Unable to create item with barcode ' + itemBarcodeAlreadyExists + ' as it exists in inventory '

  Scenario: Validation. If item is not present in inventory, new virtual item will be created.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId30 and itemBarcode30 will be created automatically
    * createDCBTransactionRequest.item.id = itemId30
    * createDCBTransactionRequest.item.barcode = itemBarcode30
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation6
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode30 + ' and itemId = ' + itemId30 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    # Cancel transaction in order to reuse the same item id and item barcode.
    * def cancelRequestEntityRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelRequestEntityRequest.cancellationReasonId = cancellationReasonId
    * cancelRequestEntityRequest.cancelledByUserId = patronId1
    * cancelRequestEntityRequest.requesterId = patronId1
    * cancelRequestEntityRequest.requestLevel = 'Item'
    * cancelRequestEntityRequest.requestType = extRequestType
    * cancelRequestEntityRequest.holdingsRecordId = holdingId
    * cancelRequestEntityRequest.itemId = itemId30
    * cancelRequestEntityRequest.pickupServicePointId = servicePointId21

    Given path 'circulation', 'requests', requestId
    And request cancelRequestEntityRequest
    When method PUT
    Then status 204

    Given path 'circulation', 'requests', requestId
    When method GET
    Then status 200
    And match $.status == 'Closed - Cancelled'

    Given path 'transactions' , dcbTransactionIdValidation6 , 'status'
    When method GET
    Then status 200
    And match $.status == 'CANCELLED'
    And match $.role == 'BORROWING-PICKUP'

  Scenario: Validation. If virtual item already exists, it will be reused. Make sure same id and barcode should be used. itemId30 reused

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    # item with id itemId30 and itemBarcode30 will be created automatically
    * createDCBTransactionRequest.item.id = itemId30
    * createDCBTransactionRequest.item.barcode = itemBarcode30
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionIdValidation7
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
    * itemEntityRequest.barcode = itemBarcode7
    * itemEntityRequest.id = itemId5
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
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + dcbTransactionId411
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
    * def orgPath = '/transactions/' + dcbTransactionId21
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    * createDCBTransactionRequest.item.id = itemId21
    * createDCBTransactionRequest.item.barcode = itemBarcode21
    * createDCBTransactionRequest.patron.id = patronId21
    * createDCBTransactionRequest.patron.barcode = patronBarcode21
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Get Item status after creating dcb transaction

    Given path 'circulation-item', itemId21
    When method GET
    Then status 200
    And match $.barcode == itemBarcode21
    And match $.status.name == 'In transit'

  Scenario: Get Service point

    Given path 'service-points', servicePointId21
    When method GET
    Then status 200
    And match $.id == servicePointId21

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode21 + ' and itemId = ' + itemId21 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'BORROWING-PICKUP'

  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to Open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWING-PICKUP'

  @CheckIn1
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcode21

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get Item status after manual check in

    Given path 'circulation-item', itemId21
    When method GET
    Then status 200
    And match $.barcode == itemBarcode21
    And match $.status.name == 'Awaiting pickup'

  @GetTransactionStatusAfterCheckIn1
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

  @CheckOut
  Scenario: do check out
    * def checkOutByBarcodeId = '3a40852d-49fd-4df2-a1f9-6e2641a6e93g'
    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.itemBarcode = itemBarcode21
    * checkOutByBarcodeEntityRequest.userBarcode = patronBarcode21
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

  Scenario: Get Item status after manual check out

    Given path 'circulation-item', itemId21
    When method GET
    Then status 200
    And match $.barcode == itemBarcode21
    And match $.status.name == 'Checked out'

  Scenario: Get request by barcode and item ID after manual check out

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode21 + ' and itemId = ' + itemId21 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

  Scenario: Get loan by item ID after manual check out

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId21 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId21


  @GetTransactionStatusAfterCheckOut
  Scenario: Check Transaction status after manual check out
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWING-PICKUP'

  @CheckIn2
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcode21

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get loan by item ID after manual check in

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId21 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId21
    And match $.loans[0].status.name == 'Closed'

  Scenario: Get Item status after manual check in 2

    Given path 'circulation-item', itemId21
    When method GET
    Then status 200
    And match $.barcode == itemBarcode21
    And match $.status.name == 'In transit'


  @GetTransactionStatusAfterCheckIn2
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWING-PICKUP'


  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId21 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWING-PICKUP'