Feature: Testing Borrowing Flow chain of Responsibility

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
    * createDCBTransactionRequest.item.id = itemId72
    * createDCBTransactionRequest.item.barcode = itemBarcode72
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId72
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId72 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId72 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'


  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId73
    * createDCBTransactionRequest.item.barcode = itemBarcode73
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId73
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'


  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT.
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId73 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId73 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWER'

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId74
    * createDCBTransactionRequest.item.barcode = itemBarcode74
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId74
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN.
    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId74 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToItemCheckedIn
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_IN
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId74 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'BORROWER'

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId75
    * createDCBTransactionRequest.item.barcode = itemBarcode75
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId75
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId75 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId75 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWER'

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId76
    * createDCBTransactionRequest.item.barcode = itemBarcode76
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId76
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId76 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT.
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId76 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId77
    * createDCBTransactionRequest.item.barcode = itemBarcode77
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId77
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId77 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN.
    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId77 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200

  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId78
    * createDCBTransactionRequest.item.barcode = itemBarcode78
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId78
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToOpen
  Scenario: Update DCB transaction status to open.
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId78 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId78 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToClosedRequest
    When method PUT
    Then status 200












  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId79
    * createDCBTransactionRequest.item.barcode = itemBarcode79
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId79
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId79 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId79 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'


  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN.
    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId79 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200


  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId80
    * createDCBTransactionRequest.item.barcode = itemBarcode80
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId80
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

  @UpdateTransactionStatusToAwaitingPickup
  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId80 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToAwaitingPickup
  Scenario: Check Transaction status after updating it to AWAITING_PICKUP
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId80 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'


  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId80 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToClosedRequest
    When method PUT
    Then status 200



  @CreateDCBTransaction
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId81
    * createDCBTransactionRequest.item.barcode = itemBarcode81
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'BORROWER'

    * def orgPath = '/transactions/' + dcbTransactionId81
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'


  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT.
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId81 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId81 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'BORROWER'

  @UpdateTransactionStatusToClosed
  Scenario: Update DCB transaction status to closed.
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-closed.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId81 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToClosedRequest
    When method PUT
    Then status 200
