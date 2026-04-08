Feature: Testing Borrower Flow Request Expiration

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 10, interval: 5000 }
    * def expBorrowerTransactionId = call uuid1
    * def expBorrowerItemId = call uuid1
    * def expBorrowerItemBarcode = call random_string

  @C1046007
  Scenario: Request expiration for BORROWER role transitions transaction to EXPIRED, check-in on any service point closes transaction
    * def createRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction-for-borrower.json')
    * createRequest.item.id = expBorrowerItemId
    * createRequest.item.barcode = expBorrowerItemBarcode
    * createRequest.patron.id = patronId1
    * createRequest.patron.barcode = patronBarcode1
    * createRequest.patron.group = patronGroupName
    * createRequest.pickup.servicePointName = 'expb_sp1'
    * createRequest.pickup.libraryCode = 'expb6'

    Given path 'transactions', expBorrowerTransactionId
    And request createRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

    Given path 'circulation-item'
    Given param query = '(barcode= ' + expBorrowerItemBarcode + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'In transit'

    * def dcbSpName = 'DCB_' + createRequest.pickup.libraryCode + '_' + createRequest.pickup.servicePointName
    Given path 'service-points'
    Given param query = '(name= ' + dcbSpName + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def dcbSp = $.servicepoints[0]
    * def dcbSpId = dcbSp.id
    * set dcbSp.holdShelfExpiryPeriod = { duration: 1, intervalId: 'Minutes' }

    Given path 'service-points', dcbSpId
    And request dcbSp
    When method PUT
    Then status 204

    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path 'transactions', expBorrowerTransactionId, 'status'
    And request updateToOpenRequest
    When method PUT
    Then status 200

    Given path 'transactions', expBorrowerTransactionId, 'status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'BORROWER'

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    Given path 'transactions', expBorrowerTransactionId, 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'circulation-item'
    Given param query = '(barcode= ' + expBorrowerItemBarcode + ')'
    When method GET
    Then status 200
    And match $.items[0].status.name == 'Awaiting pickup'

    Given path 'transactions', expBorrowerTransactionId, 'status'
    And retry until response.status == 'AWAITING_PICKUP'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'BORROWER'

    * call pause 90000
    * configure retry = { count: 30, interval: 10000 }

    Given path 'transactions', expBorrowerTransactionId, 'status'
    And retry until response.status == 'EXPIRED'
    When method GET
    Then status 200
    And match $.status == 'EXPIRED'
    And match $.role == 'BORROWER'
    * configure retry = { count: 10, interval: 5000 }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + expBorrowerItemBarcode + ')'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Pickup expired'

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = expBorrowerItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', expBorrowerTransactionId, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'BORROWER'
