Feature: Borrowing Flow Scenarios

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

  Scenario: Validation. If the userId and barcode is not exist already, error will be thrown.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId2
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = patronIdNonExisting
    * createDCBTransactionRequest.patron.barcode = patronBarcodeNonExisting
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == 'Unable to find existing user with barcode '+ patronBarcodeNonExisting + ' and id ' + patronIdNonExisting + '.'

  Scenario: Validation. If the user exist but the type is DCB, error will be thrown.

    Given path '/users/' + patronId
    When method GET
    Then status 200
    And match $.barcode == patronBarcode
    And match $.type != 'dcb'

  Scenario: Validation. If the item barcode is already present in the inventory, error will be thrown.

    * def expectedResponse = 'Barcode must be unique, 20 is already assigned to another item'

    Given call read(utilsPath+'@PostInstance')
    Given call read(utilsPath+'@PostHoldings')
    Given call read(utilsPath+'@PostItem') { barcode: itemBarcode2}

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId2
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = extUserId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 400
    And match response == expectedResponse

  Scenario: If item is not present in inventory, new virtual item will be created.
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemIdNonExisting
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = extUserId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    # message

    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcode
    * itemEntityRequest.id = karate.get('extItemId', itemIdNonExisting)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201
    
  Scenario: If virtual item already exists, it will be reused. Make sure same id and barcode should be used.
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemIdNonExisting
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = extUserId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId3
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Material type in the request should be present in inventory or else error will be thrown. If the material type is not given in the request, then we check for default material type as book in inventory, if it doesn't exist, we throw the error.

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId2
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = extUserId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1

    * createDCBTransactionRequest.item.intMaterialTypeId = intMaterialTypeIdNonExisting

    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 404
    And match $.errors[0].message == ' '

  @CreateDCBTransaction
  Scenario: Create DCB Transaction

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId2
    * createDCBTransactionRequest.item.barcode = itemBarcode2
    * createDCBTransactionRequest.patron.id = extUserId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId2
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Get Item status after creating dcb transaction

    Given path 'circulation-item', itemId2
    When method GET
    Then status 200
    And match $.barcode == itemBarcode2
    And match $.status.name == 'In transit'

  Scenario: Get Service point

    Given path 'service-points', servicePointId1
    When method GET
    Then status 200
    And match $.id == servicePointId1

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode2 + ' and itemId = ' + itemId2 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWER'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  Scenario: Get Item status after updating it to awaiting pickup

    Given path 'circulation-item', itemId2
    When method GET
    Then status 200
    And match $.barcode == itemBarcode2
    And match $.status.name == 'Awaiting pickup'


  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'


  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT.
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200

  Scenario: Get Item status after updating it to ITEM_CHECKED_OUT

    Given path 'circulation-item', itemId2
    When method GET
    Then status 200
    And match $.barcode == itemBarcode2
    And match $.status.name == 'Checked out'


  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWER'

  Scenario: Get request by barcode and item ID after updating it to ITEM_CHECKED_OUT

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode2 + ' and itemId = ' + itemId2 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

  Scenario: Get loan by item ID after updating it to ITEM_CHECKED_OUT

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId2 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == extUserId1

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN.
    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200

  Scenario: Get loan by item ID after updating to ITEM_CHECKED_IN

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId2 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == extUserId1

  Scenario: Get Item status after updating it to ITEM_CHECKED_IN

    Given path 'circulation-item', itemId2
    When method GET
    Then status 200
    And match $.barcode == itemBarcode2
    And match $.status.name == 'In transit'


  @GetTransactionStatusAfterUpdatingToItemCheckedIn
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_IN
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWER'

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId2 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWER'