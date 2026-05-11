Feature: Lender Virtual Patron Group Update

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
    * def txnId1 = 'c648462a'
    * def txnId2 = 'c648462b'
    * def virtualPatronId = 'c6484620-0001-4000-8000-000000000001'
    * def virtualPatronBarcode = 'FAT-648462-patron'
    * def itemId1 = 'c6484620-0002-4000-8000-000000000001'
    * def itemBarcode1 = 'FAT-648462-item-1'
    * def itemId2 = 'c6484620-0002-4000-8000-000000000002'
    * def itemBarcode2 = 'FAT-648462-item-2'
    * def secondGroupId = 'c6484620-0003-4000-8000-000000000001'
    * def secondGroupName = 'dcb-group-c648462'

  @C648462
  Scenario: Verify LENDER virtual patron group updates when second transaction uses a different patron group

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrl
    Given path 'inventory', 'items'
    And request
      """
      {
        "id": "#(itemId1)",
        "holdingsRecordId": "#(holdingId)",
        "barcode": "#(itemBarcode1)",
        "materialType": { "id": "#(intMaterialTypeId)" },
        "permanentLoanType": { "id": "#(permanentLoanTypeId)" },
        "status": { "name": "Available" }
      }
      """
    When method POST
    Then status 201

    Given path 'inventory', 'items'
    And request
      """
      {
        "id": "#(itemId2)",
        "holdingsRecordId": "#(holdingId)",
        "barcode": "#(itemBarcode2)",
        "materialType": { "id": "#(intMaterialTypeId)" },
        "permanentLoanType": { "id": "#(permanentLoanTypeId)" },
        "status": { "name": "Available" }
      }
      """
    When method POST
    Then status 201

    Given path 'groups'
    And request { id: '#(secondGroupId)', group: '#(secondGroupName)' }
    When method POST
    Then status 201

    * url baseUrlNew
    * def createReq1 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq1.item.id = itemId1
    * createReq1.item.barcode = itemBarcode1
    * createReq1.patron.id = virtualPatronId
    * createReq1.patron.group = patronGroupName
    * createReq1.patron.barcode = virtualPatronBarcode
    * createReq1.pickup.servicePointName = 'lending-sp-c648462-1'
    * createReq1.pickup.libraryCode = 'lib-c648462-1'
    * createReq1.role = 'LENDER'

    * def orgPath1 = '/transactions/' + txnId1
    * def newPath1 = proxyCall == true ? proxyPath + orgPath1 : orgPath1

    Given path newPath1
    And param apikey = key
    And request createReq1
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.patron.id == virtualPatronId

    * url baseUrl
    Given path 'users', virtualPatronId
    When method GET
    Then status 200
    And match $.barcode == virtualPatronBarcode
    And match $.type == 'dcb'
    And match $.patronGroup == patronGroupId

    Given path 'request-storage', 'requests'
    And param query = 'requesterId==' + virtualPatronId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    * url baseUrlNew
    * def createReq2 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq2.item.id = itemId2
    * createReq2.item.barcode = itemBarcode2
    * createReq2.patron.id = virtualPatronId
    * createReq2.patron.group = secondGroupName
    * createReq2.patron.barcode = virtualPatronBarcode
    * createReq2.pickup.servicePointName = 'lending-sp-c648462-2'
    * createReq2.pickup.libraryCode = 'lib-c648462-2'
    * createReq2.role = 'LENDER'

    * def orgPath2 = '/transactions/' + txnId2
    * def newPath2 = proxyCall == true ? proxyPath + orgPath2 : orgPath2

    Given path newPath2
    And param apikey = key
    And request createReq2
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.patron.id == virtualPatronId
    And match $.patron.group == secondGroupName

    * url baseUrl
    Given path 'users', virtualPatronId
    When method GET
    Then status 200
    And match $.type == 'dcb'
    And match $.patronGroup == secondGroupId

    Given path 'request-storage', 'requests'
    And param query = 'requesterId==' + virtualPatronId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
