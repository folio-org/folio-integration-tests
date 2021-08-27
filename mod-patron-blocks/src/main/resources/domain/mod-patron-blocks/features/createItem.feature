Feature:

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def materialTypeId = call uuid1
    * def permanentLoanTypeId = call uuid1
    * def temporaryLoanTypeId = call uuid1
    * def temporaryLocationId = call uuid1
    * def itemId = call uuid1
    * def itemBarcode = call uuid

    Scenario: Create item
      * def item = read('samples/item-entity.json')
      * item.holdingsRecordId = hrid
      * def checkOutRequest = read('samples/check-out-request.json')
      * checkOutRequest.userBarcode = userBarcode
      * checkOutRequest.proxyUserBarcode = proxyUserBarcode
      * checkOutRequest.itemBarcode = itemBarcode
      * checkOutRequest.servicePointId = servicePointId

      Given path 'inventory/items'
      And request item
      When method POST
      Then status 201

      Given path 'circulation/check-out-by-barcode'
      And request checkOutRequest
      When method POST
      Then status 201





