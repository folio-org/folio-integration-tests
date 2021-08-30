Feature:

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def permanentLoanTypeId = call uuid1
    * def temporaryLoanTypeId = call uuid1
    * def temporaryLocationId = call uuid1
    * def itemId = call uuid1
    * def itemBarcode = call uuid

    Scenario: Create item and checkout
      * def item = read('samples/item-entity.json')
      # * item.hrid = hrid
      * item.holdingsRecordId = holdingsRecordId
      * def checkOutRequest = read('samples/check-out-request.json')
      * checkOutRequest.userBarcode = userBarcode
      * checkOutRequest.itemBarcode = itemBarcode
      * checkOutRequest.servicePointId = servicePointId
      * item.materialType = {id: materialTypeId}

      Given path 'inventory/items'
      And request item
      When method POST
      Then status 201

      Given path 'circulation/check-out-by-barcode'
      And request checkOutRequest
      When method POST
      Then status 201





