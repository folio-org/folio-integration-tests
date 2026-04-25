Feature: Testing Lending Flow Request Expiration

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersUser
    * callonce variables
    * configure retry = { count: 10, interval: 5000 }
    * def expLenderTransactionId = call uuid1
    * def expLenderPatronId = call uuid1
    * def expLenderPatronBarcode = call random_string
    * def expLenderItemId = call uuid1
    * def expLenderItemBarcode = call random_string

  @C1046007
  Scenario: Request expiration for LENDER role transitions transaction to EXPIRED, check-in at any service point closes transaction
    * def newItemPayload = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * newItemPayload.id = expLenderItemId
    * newItemPayload.barcode = expLenderItemBarcode
    * newItemPayload.materialType.id = intMaterialTypeId

    Given path 'inventory', 'items'
    And request newItemPayload
    When method POST
    Then status 201

    * def createRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createRequest.item.id = expLenderItemId
    * createRequest.item.barcode = expLenderItemBarcode
    * createRequest.patron.id = expLenderPatronId
    * createRequest.patron.barcode = expLenderPatronBarcode
    * createRequest.patron.group = patronGroupName
    * createRequest.pickup.servicePointName = 'exp_lend_sp1'
    * createRequest.pickup.libraryCode = 'expl6'
    * createRequest.role = 'LENDER'

    Given path 'transactions', expLenderTransactionId
    And request createRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'

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

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = expLenderItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', expLenderTransactionId, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    Given path 'transactions', expLenderTransactionId, 'status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', expLenderTransactionId, 'status'
    And retry until response.status == 'AWAITING_PICKUP'
    When method GET
    Then status 200
    And match $.status == 'AWAITING_PICKUP'
    And match $.role == 'LENDER'

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + expLenderItemBarcode + ' and itemId = ' + expLenderItemId + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].status == 'Open - Awaiting pickup'

    * call pause 90000
    * configure retry = { count: 30, interval: 10000 }

    Given path 'transactions', expLenderTransactionId, 'status'
    And retry until response.status == 'EXPIRED'
    When method GET
    Then status 200
    And match $.status == 'EXPIRED'
    And match $.role == 'LENDER'
    * configure retry = { count: 10, interval: 5000 }

    Given path 'request-storage', 'requests'
    Given param query = '(item.barcode= ' + expLenderItemBarcode + ' and itemId = ' + expLenderItemId + ')'
    When method GET
    Then status 200
    And match $.requests[0].status == 'Closed - Pickup expired'

    * def intCheckInDate2 = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest2.servicePointId = servicePointId11
    * checkInRequest2.itemBarcode = expLenderItemBarcode

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest2
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', expLenderTransactionId, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
    And match $.status == 'CLOSED'
    And match $.role == 'LENDER'
