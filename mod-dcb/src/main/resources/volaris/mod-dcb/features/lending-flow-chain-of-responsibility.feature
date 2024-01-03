Feature: Testing Lending Flow chain of Responsibility

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


  @CreateDCBTransaction1
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId51
    * createDCBTransactionRequest.item.barcode = itemBarcode51
    * createDCBTransactionRequest.patron.id = patronId11
    * createDCBTransactionRequest.patron.barcode = patronBarcode11
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
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId51
    And match $.patron.id == patronId11

  @CheckIn1
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode51
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode51
    And match $.item.status.name == 'In transit'
    * call pause 5000

  @GetTransactionStatusAfterCheckIn
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId51 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToItemCheckedOut
  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT
    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId51 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request updateToCheckOutRequest
    When method PUT
    Then status 200

  @GetTransactionStatusAfterUpdatingToItemCheckedOut
  Scenario: Check Transaction status after updating it to ITEM_CHECKED_OUT
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId51 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'
    And match $.role == 'LENDER'

  @CreateDCBTransaction2
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId61
    * createDCBTransactionRequest.item.barcode = itemBarcode61
    * createDCBTransactionRequest.patron.id = patronId11
    * createDCBTransactionRequest.patron.barcode = patronBarcode11
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId61
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId61
    And match $.patron.id == patronId11

  @CheckIn2
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode61
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode61
    And match $.item.status.name == 'In transit'
    * call pause 5000

  @GetTransactionStatusAfterCheckIn
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId61 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToItemCheckedIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN
    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId61 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId61 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'LENDER'

  @CreateDCBTransaction3
  Scenario: Create DCB Transaction
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId71
    * createDCBTransactionRequest.item.barcode = itemBarcode71
    * createDCBTransactionRequest.patron.id = patronId11
    * createDCBTransactionRequest.patron.barcode = patronBarcode11
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.pickup.servicePointName = servicePointName21
    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId71
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId71
    And match $.patron.id == patronId11


  @CheckIn3
  Scenario: current item check-in record and its status
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode71
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode71
    And match $.item.status.name == 'In transit'
    * call pause 5000

  @GetTransactionStatusAfterCheckIn
  Scenario: Check Transaction status after manual check in
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId71 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId71 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId71 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

  @UpdateTransactionStatusToItemCheckIn
  Scenario: Update DCB transaction status to ITEM_CHECKED_IN
    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def orgPath = '/transactions/' + dcbTransactionId71 + '/status'
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
    * def orgPath = '/transactions/' + dcbTransactionId71 + '/status'
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'
    And match $.role == 'LENDER'