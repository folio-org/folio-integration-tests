Feature: Testing Borrowing-Pickup Flow Request Expiration

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 10, interval: 5000 }
    * def expBPTransactionId = call uuid1
    * def expBPItemId = call uuid1
    * def expBPItemBarcode = call random_string
    * def expBPSpId = call uuid1
    * def expBPSpName = call random_string
    * def expBPSpCode = call random_string

  @C1046007
  Scenario: Request expiration for BORROWING_PICKUP role transitions transaction to EXPIRED, check-in on any service point closes transaction
    * def servicePointEntityRequest = read('classpath:volaris/mod-dcb/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = expBPSpId
    * servicePointEntityRequest.name = expBPSpName
    * servicePointEntityRequest.code = expBPSpCode
    * servicePointEntityRequest.holdShelfExpiryPeriod = { duration: 1, intervalId: 'Minutes' }

    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def createRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-for-borrowing-pickup.json')
    * createRequest.item.id = expBPItemId
    * createRequest.item.barcode = expBPItemBarcode
    * createRequest.patron.id = patronId21
    * createRequest.patron.barcode = patronBarcode21
    * createRequest.patron.group = patronGroupName
    * createRequest.pickup.servicePointId = expBPSpId
    * createRequest.pickup.servicePointName = expBPSpName

    Given path 'transactions', expBPTransactionId
    And request createRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'circulation-item'
    Given param query = '(barcode= ' + expBPItemBarcode + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path 'transactions', expBPTransactionId, 'status'
    And request updateToOpenRequest
    When method PUT
    Then status 200

    Given path 'transactions', expBPTransactionId, 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWING-PICKUP'

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = expBPSpId
    * checkInRequest.itemBarcode = expBPItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'Awaiting pickup'
    * call pause 5000

    Given path 'transactions', expBPTransactionId, 'status'
    And retry until response.status == 'AWAITING_PICKUP'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWING-PICKUP'

    * call pause 90000
    * configure retry = { count: 30, interval: 10000 }

    Given path 'transactions', expBPTransactionId, 'status'
    And retry until response.status == 'EXPIRED'
    When method GET
    Then status 200
    And match $.status == 'EXPIRED'
    And match $.role == 'BORROWING-PICKUP'
    * configure retry = { count: 10, interval: 5000 }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + expBPItemBarcode + ')'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Pickup expired'

    * def intCheckInDate2 = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest2.servicePointId = servicePointId11
    * checkInRequest2.itemBarcode = expBPItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest2
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', expBPTransactionId, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWING-PICKUP'
