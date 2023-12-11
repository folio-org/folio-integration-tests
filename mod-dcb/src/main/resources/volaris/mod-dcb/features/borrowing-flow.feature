Feature: Testing Borrowing-Pickup Flow

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
#    And match $.status.name == 'Checked in'
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