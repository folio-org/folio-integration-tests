Feature: Borrower Transaction Service Point Hold Shelf

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
    * def txnId = '648504'
    * def itemTitle648504 = 'DCB Item Title C648504'
    * def itemBarcode648504 = '648504bc'
    * def pickupSpName = 'borrower_sp_648504'
    * def pickupLibCode = 'lib648504'

  @C648504
  Scenario: Create BORROWER DCB transaction and verify DCB service point is created with 10-day hold shelf expiry period

    # Step 1: Create DCB transaction with role = BORROWER using existing patron
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.title = itemTitle648504
    * createReq.item.barcode = itemBarcode648504
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.pickup.servicePointName = pickupSpName
    * createReq.pickup.libraryCode = pickupLibCode
    * createReq.role = 'BORROWER'

    * def orgPath = '/transactions/' + txnId
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcode648504
    And match $.patron.id == patronId31

    # Step 2: Verify DCB service point was auto-created with name "DCB_<libraryCode>_<servicePointName>"
    * def dcbSpName = 'DCB_' + pickupLibCode + '_' + pickupSpName
    * url baseUrl

    Given path 'service-points'
    And param query = '(name= ' + dcbSpName + ')'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.servicepoints[0].name == dcbSpName

    # Step 3: Verify "Hold shelf expiration period" is set to 10 days by default
    And match $.servicepoints[0].holdShelfExpiryPeriod.duration == 10
    And match $.servicepoints[0].holdShelfExpiryPeriod.intervalId == 'Days'
