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
    * def orgPath = '/transactions/' + dcbTransactionId1
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath
    * createDCBTransactionRequest.item.id = itemId1
    * createDCBTransactionRequest.item.barcode = itemBarcode1
    * createDCBTransactionRequest.patron.id = patronId1
    * createDCBTransactionRequest.patron.barcode = patronBarcode1
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId1
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName1
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  Scenario: Get Item status after creating dcb transaction

    Given path 'circulation-item', itemId1
    When method GET
    Then status 200
    And match $.barcode == itemBarcode1
    And match $.status.name == 'In transit'

  Scenario: Get Service point

    Given path 'service-points', servicePointId1
    When method GET
    Then status 200
    And match $.id == servicePointId1

  Scenario: Get request by barcode and item ID after creating dcb transaction

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode1 + ' and itemId = ' + itemId1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Not yet filled'

  @GetTransactionStatusAfterCreatingDCBTransaction
  Scenario: Check Transaction status after creating dcb transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * checkInRequest.servicePointId = servicePointId1
    * checkInRequest.itemBarcode = itemBarcode1

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get Item status after manual check in

    Given path 'circulation-item', itemId1
    When method GET
    Then status 200
    And match $.barcode == itemBarcode1
    And match $.status.name == 'Awaiting pickup'

  @GetTransactionStatusAfterCheckIn1
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * def checkOutByBarcodeEntityRequest = read('samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.itemBarcode = itemBarcode1
    * checkOutByBarcodeEntityRequest.userBarcode = patronBarcode1

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

  Scenario: Get Item status after manual check out

    Given path 'circulation-item', itemId1
    When method GET
    Then status 200
    And match $.barcode == itemBarcode1
    And match $.status.name == 'Checked out'

  Scenario: Get request by barcode and item ID after manual check out

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + itemBarcode1 + ' and itemId = ' + itemId1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Closed - Filled'

  Scenario: Get loan by item ID after manual check out

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId1


  @GetTransactionStatusAfterCheckOut
  Scenario: Check Transaction status after manual check out
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * checkInRequest.servicePointId = servicePointId1
    * checkInRequest.itemBarcode = itemBarcode1

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

  Scenario: Get loan by item ID after manual check in

    Given path 'loan-storage', 'loans'
    Given param query = '( itemId = ' + itemId1 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId1
    And match $.loans[0].status.name == 'Closed'

  Scenario: Get Item status after manual check in 2

    Given path 'circulation-item', itemId1
    When method GET
    Then status 200
    And match $.barcode == itemBarcode1
    And match $.status.name == 'In transit'


  @GetTransactionStatusAfterCheckIn2
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId1 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWING-PICKUP'