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
    * def holdingsRecordId = call uuid1
    * def itemBarcode = call random(100000)

    Scenario: Create item
      * def item = read('samples/item-entity.json')
      * def checkOutRequest = read('samples/check-out-request.json')
      * checkOutRequest.userBarcode = userBarcode
      * checkOutRequest.proxyUserBarcode = userBarcode
      * checkOutRequest.itemBarcode = itemBarcode

      Given path 'inventory/items'
      And request item
      When method POST
      Then status 201

      Given path 'circulation/check-out-by-barcode'
      And request read ('samples/check-out-request')





