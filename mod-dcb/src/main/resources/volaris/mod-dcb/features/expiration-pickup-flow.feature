Feature: Testing Pickup Flow Request Expiration

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 10, interval: 5000 }
    * def expPickupTransactionId = call uuid1
    * def expPickupItemId = call uuid1
    * def expPickupItemBarcode = call random_string
    * def expPickupPatronId = call uuid1
    * def expPickupPatronBarcode = call random_string
    * def expPickupSpId = call uuid1
    * def expPickupSpName = call random_string
    * def expPickupSpCode = call random_string

  @C1046007
  Scenario: Request expiration for PICKUP role transitions transaction to EXPIRED, check-in on any service point closes transaction
    * def servicePointEntityRequest = read('classpath:volaris/mod-dcb/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = expPickupSpId
    * servicePointEntityRequest.name = expPickupSpName
    * servicePointEntityRequest.code = expPickupSpCode
    * servicePointEntityRequest.holdShelfExpiryPeriod = { duration: 1, intervalId: 'Minutes' }

    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def createRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-for-pickup.json')
    * createRequest.item.id = expPickupItemId
    * createRequest.item.barcode = expPickupItemBarcode
    * createRequest.patron.id = expPickupPatronId
    * createRequest.patron.barcode = expPickupPatronBarcode
    * createRequest.patron.group = patronGroupName
    * createRequest.pickup.servicePointId = expPickupSpId
    * createRequest.pickup.servicePointName = expPickupSpName

    Given path 'transactions', expPickupTransactionId
    And request createRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'circulation-item'
    Given param query = '(barcode= ' + expPickupItemBarcode + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path 'transactions', expPickupTransactionId, 'status'
    And request updateToOpenRequest
    When method PUT
    Then status 200

    Given path 'transactions', expPickupTransactionId, 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'PICKUP'

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = expPickupSpId
    * checkInRequest.itemBarcode = expPickupItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions', expPickupTransactionId, 'status'
    And retry until response.status == 'AWAITING_PICKUP'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'PICKUP'

    * call pause 90000
    * configure retry = { count: 30, interval: 10000 }

    Given path 'transactions', expPickupTransactionId, 'status'
    And retry until response.status == 'EXPIRED'
    When method GET
    Then status 200
    And match $.status == 'EXPIRED'
    And match $.role == 'PICKUP'
    * configure retry = { count: 10, interval: 5000 }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + expPickupItemBarcode + ')'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Pickup expired'

    * def intCheckInDate2 = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest2.servicePointId = servicePointId11
    * checkInRequest2.itemBarcode = expPickupItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest2
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', expPickupTransactionId, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'PICKUP'
