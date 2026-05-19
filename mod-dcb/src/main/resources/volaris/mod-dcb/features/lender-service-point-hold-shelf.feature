Feature: Lender Transaction Service Point Hold Shelf

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
    * def itemId430227 = 'f4302270-4302-4302-b962-430227430227'
    * def itemBarcode430227 = '430227'
    * def txnId = '430227'
    * def lenderPatronId = 'ea430227-4302-4302-b962-000000430227'
    * def lenderPatronBarcode = 'FAT-430227-P'
    * def pickupSpName = 'lending_sp_430227'
    * def pickupLibCode = 'lib430227'

  @C430227
  Scenario: Create LENDER DCB transaction and verify DCB service point is created with 10-day hold shelf expiry period

    # Precondition: create item in Available status in Inventory
    * def itemReq = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemReq.id = itemId430227
    * itemReq.barcode = itemBarcode430227
    * itemReq.materialType.id = intMaterialTypeId

    * url baseUrl
    Given path 'inventory', 'items'
    And request itemReq
    When method POST
    Then status 201

    # Step 1: Create DCB transaction with role = LENDER
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId430227
    * createReq.item.barcode = itemBarcode430227
    * createReq.patron.id = lenderPatronId
    * createReq.patron.barcode = lenderPatronBarcode
    * createReq.patron.group = patronGroupName
    * createReq.pickup.servicePointName = pickupSpName
    * createReq.pickup.libraryCode = pickupLibCode
    * createReq.role = 'LENDER'

    * def orgPath = '/transactions/' + txnId
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId430227
    And match $.patron.id == lenderPatronId

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
