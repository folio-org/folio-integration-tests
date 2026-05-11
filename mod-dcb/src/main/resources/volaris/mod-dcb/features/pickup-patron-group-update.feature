Feature: Pickup Patron Group Update

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
    * def txnId1 = 'c648463-1'
    * def txnId2 = 'c648463-2'
    * def txnItemId1 = 'c6484630-0001-4000-8000-000000000001'
    * def txnItemId2 = 'c6484630-0001-4000-8000-000000000002'
    * def txnItemBarcode1 = 'c648463-item-1'
    * def txnItemBarcode2 = 'c648463-item-2'
    * def txnPatronId = 'c6484630-0000-4000-8000-000000000001'
    * def txnPatronBarcode = 'c648463-patron'

  @C648463
  Scenario: Create two PICKUP transactions for same virtual patron and verify patron group update
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    # Step 1: Create first PICKUP transaction to generate virtual patron with first patron group
    * def createReq1 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq1.item.id = txnItemId1
    * createReq1.item.title = 'DCB Item C648463-1'
    * createReq1.item.barcode = txnItemBarcode1
    * createReq1.item.materialType = materialTypeName
    * createReq1.item.lendingLibraryCode = 'test-lib-c648463'
    * createReq1.patron.id = txnPatronId
    * createReq1.patron.group = patronGroupName
    * createReq1.patron.barcode = txnPatronBarcode
    * createReq1.pickup.servicePointId = servicePointId
    * createReq1.pickup.servicePointName = servicePointName
    * createReq1.role = 'PICKUP'

    * def orgPath1 = '/transactions/' + txnId1
    * def newPath1 = proxyCall == true ? proxyPath + orgPath1 : orgPath1
    Given path newPath1
    And param apikey = key
    And request createReq1
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.patron.id == txnPatronId

    # Step 1 (verify): Virtual user exists with type "dcb" and first patron group
    * url baseUrl
    Given path 'users', txnPatronId
    When method GET
    Then status 200
    And match $.type == 'dcb'
    And match $.barcode == txnPatronBarcode
    And match $.patronGroup == patronGroupId

    # Step 2: Verify 1 open request exists for the virtual patron
    Given path 'request-storage', 'requests'
    And param query = 'requesterId==' + txnPatronId + ' AND status=="Open - Not yet filled"'
    When method GET
    Then status 200
    And match $.totalRecords == 1

    # Step 3: Create second PICKUP transaction for same patron with second patron group and new item barcode
    * url baseUrlNew
    * def createReq2 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq2.item.id = txnItemId2
    * createReq2.item.title = 'DCB Item C648463-2'
    * createReq2.item.barcode = txnItemBarcode2
    * createReq2.item.materialType = materialTypeName
    * createReq2.item.lendingLibraryCode = 'test-lib-c648463'
    * createReq2.patron.id = txnPatronId
    * createReq2.patron.group = patronName
    * createReq2.patron.barcode = txnPatronBarcode
    * createReq2.pickup.servicePointId = servicePointId
    * createReq2.pickup.servicePointName = servicePointName
    * createReq2.role = 'PICKUP'

    * def orgPath2 = '/transactions/' + txnId2
    * def newPath2 = proxyCall == true ? proxyPath + orgPath2 : orgPath2
    Given path newPath2
    And param apikey = key
    And request createReq2
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.patron.id == txnPatronId

    # Step 4: Verify virtual user's patron group was updated to second group
    * url baseUrl
    Given path 'users', txnPatronId
    When method GET
    Then status 200
    And match $.type == 'dcb'
    And match $.patronGroup == patronId

    # Step 5: Verify 2 open requests exist for the virtual patron
    Given path 'request-storage', 'requests'
    And param query = 'requesterId==' + txnPatronId + ' AND status=="Open - Not yet filled"'
    When method GET
    Then status 200
    And match $.totalRecords == 2
