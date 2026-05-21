Feature: Testing Borrowing-Pickup Self-Borrowing Flow

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
    * configure retry = { count: 5, interval: 1000 }
    * def sbTransactionId = call uuid1
    * def sbItemId = call uuid1
    * def sbItemBarcode = call random_string

  @C773214
  Scenario: Create BORROWING-PICKUP transaction with selfBorrowing and verify full status lifecycle

    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.id = sbItemId
    * itemEntityRequest.barcode = sbItemBarcode
    * itemEntityRequest.holdingsRecordId = holdingId
    * itemEntityRequest.materialType.id = intMaterialTypeId
    * itemEntityRequest.materialType.name = materialTypeName
    * itemEntityRequest.status.name = 'Available'
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = sbItemId
    * createDCBTransactionRequest.item.barcode = sbItemBarcode
    * createDCBTransactionRequest.patron.id = patronId31
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.patron.barcode = patronBarcode31
    * createDCBTransactionRequest.pickup.servicePointId = servicePointId21
    * createDCBTransactionRequest.role = 'BORROWING-PICKUP'
    * createDCBTransactionRequest.selfBorrowing = true

    * def orgPath = '/transactions/' + sbTransactionId
    * def newPath = proxyCall == true ? proxyPath+orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == sbItemBarcode
    And match $.patron.id == patronId31

    * def orgPathStatus = '/transactions/' + sbTransactionId + '/status'
    * def newPathStatus = proxyCall == true ? proxyPath+orgPathStatus : orgPathStatus
    Given path newPathStatus
    And param apikey = key
    When method GET
    Then status 200
    And match $.status == 'CREATED'
    And match $.role == 'BORROWING-PICKUP'

    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = sbItemBarcode
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

    Given path 'inventory', 'items', sbItemId
    When method GET
    Then status 200
    And match $.status.name == 'Awaiting pickup'

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'AWAITING_PICKUP' && response.role == 'BORROWING-PICKUP'
    When method GET
    Then status 200

    * url baseUrl
    * def checkOutByBarcodeId = call uuid1
    * def checkOutByBarcodeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.itemBarcode = sbItemBarcode
    * checkOutByBarcodeEntityRequest.userBarcode = patronBarcode31
    * checkOutByBarcodeEntityRequest.servicePointId = servicePointId21
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
    * call pause 5000

    Given path 'inventory', 'items', sbItemId
    When method GET
    Then status 200
    And match $.status.name == 'Checked out'

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'ITEM_CHECKED_OUT' && response.role == 'BORROWING-PICKUP'
    When method GET
    Then status 200

    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId
    * checkInRequest.itemBarcode = sbItemBarcode
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    * call pause 5000

    Given path 'inventory', 'items', sbItemId
    When method GET
    Then status 200
    And match $.status.name == 'Available'

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'CLOSED' && response.role == 'BORROWING-PICKUP'
    When method GET
    Then status 200
