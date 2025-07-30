Feature: Testing Lending Flow chain of Responsibility

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? admin : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * callonce variables


  Scenario: Create and Update DCB Transaction from OPEN to ITEM_CHECKED_OUT
    * def transactionId = '04040'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(itemId51)', itemBarcode: '#(itemBarcode51)' }
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

    Given path '/transactions/' + transactionId + '/status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

    * def updateToCheckOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToCheckOutRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'

  Scenario: Create and Update DCB Transaction from OPEN to ITEM_CHECKED_IN
    * def transactionId = '04041'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(itemId61)', itemBarcode: '#(itemBarcode61)' }
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

    Given path '/transactions/' + transactionId + '/status'
    When method GET
    Then status 200
    And match $.status == 'OPEN'
    And match $.role == 'LENDER'

    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToCheckInRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'

  Scenario: Create and Update DCB Transaction from AWAITING_PICKUP to ITEM_CHECKED_IN
    * def transactionId = '04042'
    * def createTransaction = call read('classpath:volaris/mod-dcb/reusable/create-dcb-transaction.feature') { transactionId: '#(transactionId)', extItemId: '#(itemId71)', itemBarcode: '#(itemBarcode71)' }
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

    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    And match $.status == 'AWAITING_PICKUP'

    * def updateToCheckInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToCheckInRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'