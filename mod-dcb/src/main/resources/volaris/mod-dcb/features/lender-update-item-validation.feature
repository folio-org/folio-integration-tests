Feature: Lender Update Item Validation

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

    * def itemId627524 = 'c6275240-627f-4524-8000-000000000001'
    * def itemBarcode627524 = 'item627524'
    * def patronId627524 = 'c6275240-627f-4524-8000-000000000002'
    * def patronBarcode627524 = 'pat627524'
    * def dcbTransactionId627524 = '627524'
    * def itemBarcodeUpdate627524 = 'upd627524'

    * def itemEntityRequest627524 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest627524.barcode = itemBarcode627524
    * itemEntityRequest627524.id = itemId627524
    * itemEntityRequest627524.holdingsRecordId = holdingId
    * itemEntityRequest627524.materialType.id = intMaterialTypeId
    * itemEntityRequest627524.status.name = intStatusName
    Given path 'inventory', 'items'
    And request itemEntityRequest627524
    When method POST
    Then status 201

  @C627524
  Scenario: Updating item details for LENDER role returns 400 error

    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createDCBTransactionRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createDCBTransactionRequest.item.id = itemId627524
    * createDCBTransactionRequest.item.barcode = itemBarcode627524
    * createDCBTransactionRequest.patron.id = patronId627524
    * createDCBTransactionRequest.patron.barcode = patronBarcode627524
    * createDCBTransactionRequest.patron.group = patronGroupName
    * createDCBTransactionRequest.pickup.servicePointName = 'lending_sp1'
    * createDCBTransactionRequest.pickup.libraryCode = '6uclv'
    * createDCBTransactionRequest.role = 'LENDER'

    * def orgPath = '/transactions/' + dcbTransactionId627524
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath

    Given path newPath
    And param apikey = key
    And request createDCBTransactionRequest
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId627524
    And match $.patron.id == patronId627524

    * url baseUrl
    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + itemBarcode627524 + ' and itemId = ' + itemId627524 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].requestType == 'Page'
    And match $.requests[0].status == 'Open - Not yet filled'
    * def requestId = $.requests[0].id

    * url baseUrlNew
    Given path newPath
    And request
      """
      {
        "item": {
          "barcode": "#(itemBarcodeUpdate627524)",
          "materialType": "#(materialTypeName)",
          "lendingLibraryCode": "KU"
        }
      }
      """
    When method PUT
    Then status 400
    And match $.errors[0].message == 'Item details cannot be updated for lender role'
    And match $.errors[0].type == '-1'
    And match $.errors[0].code == 'VALIDATION_ERROR'
    And match $.errors[0].parameters == []

    * url baseUrl
    Given path 'request-storage', 'requests'
    And param query = '(item.barcode= ' + itemBarcode627524 + ' and itemId = ' + itemId627524 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.requests[0].requestType == 'Page'
    And match $.requests[0].status == 'Open - Not yet filled'
    And match $.requests[0].id == requestId
    And match $.requests[0].item.barcode == itemBarcode627524
