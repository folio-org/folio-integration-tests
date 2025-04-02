Feature: Testing Borrowing Flow chain of Responsibility

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

  Scenario: Create Transaction and updating it from CREATED to AWAITING_PICKUP.
    * def transactionId = '10072'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac120007'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '172' }
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    And match $.status == 'AWAITING_PICKUP'

  Scenario: Create Transaction and updating it from CREATED to ITEM_CHECKED_OUT.
    * def transactionId = '10073'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac120008'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '173' }
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'

  Scenario: Create Transaction and updating it from CREATED to ITEM_CHECKED_IN.
    * def transactionId = '10074'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac120009'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '174' }
    * def updateToItemCheckInRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckInRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'

  Scenario: Create Transaction and updating it from CREATED to CLOSED.
    * def transactionId = '10075'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130001'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '175' }
    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-closed.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToClosedRequest
    When method PUT
    Then status 200
    And match $.status == 'CLOSED'

  Scenario: Create Transaction and updating it from OPEN to ITEM_CHECKED_OUT.
    * def transactionId = '10076'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130002'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '176' }
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-open.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToOpenRequest
    When method PUT
    Then status 200
    And match $.status == 'OPEN'

    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'

  Scenario: Create Transaction and updating it from OPEN to ITEM_CHECKED_IN.
    * def transactionId = '10077'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130003'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '177' }
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-open.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToOpenRequest
    When method PUT
    Then status 200
    And match $.status == 'OPEN'

    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'


  Scenario: Create Transaction and updating it from OPEN to CLOSED.
    * def transactionId = '10078'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130004'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '178' }
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-open.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToOpenRequest
    When method PUT
    Then status 200
    And match $.status == 'OPEN'

    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-closed.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToClosedRequest
    When method PUT
    Then status 200
    And match $.status == 'CLOSED'

  Scenario: Create Transaction and updating it from AWAITING_PICKUP to ITEM_CHECKED_IN.
    * def transactionId = '10079'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130005'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '179' }
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    And match $.status == 'AWAITING_PICKUP'

    * def updateToItemCheckinRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckinRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_IN'

  Scenario: Create Transaction and updating it from AWAITING_PICKUP to CLOSED.
    * def transactionId = '10080'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130006'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '180' }
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200
    And match $.status == 'AWAITING_PICKUP'

    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-closed.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToClosedRequest
    When method PUT
    Then status 200
    And match $.status == 'CLOSED'

  Scenario: Create Transaction and updating it from ITEM_CHECKED_OUT to CLOSED.
    * def transactionId = '10081'
    * def id1 = '3c497cc0-77b7-11ee-b962-0242ac130007'
    * def createTransaction = call read('classpath:volaris/mod-dcb/eureka-reusable/create-dcb-transaction-for-borrower.feature') { transactionId: '#(transactionId)', extItemId: '#(id1)', itemBarcode: '181' }
    * def updateToItemCheckoutRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToItemCheckoutRequest
    When method PUT
    Then status 200
    And match $.status == 'ITEM_CHECKED_OUT'

    * def updateToClosedRequest = read('classpath:volaris/mod-dcb/eureka-features/samples/transaction/update-dcb-transaction-to-closed.json')

    Given path '/transactions/' + transactionId + '/status'
    And request updateToClosedRequest
    When method PUT
    Then status 200
    And match $.status == 'CLOSED'