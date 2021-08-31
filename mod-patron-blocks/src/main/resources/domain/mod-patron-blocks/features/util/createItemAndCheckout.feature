Feature: Create item and checkout

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def permanentLoanTypeId = call uuid1
    * def temporaryLoanTypeId = call uuid1
    * def temporaryLocationId = call uuid1
    * def itemId = call uuid1
    # * def itemBarcode = call uuid

  @PostItem
  Scenario: Create item
    * def item = read('classpath:domain/mod-patron-blocks/features/samples/item-entity.json')
    * item.holdingsRecordId = holdingsRecordId
    * item.materialType = {id: materialTypeId}
    * item.barcode = itemBarcode

    Given path 'inventory/items'
    And request item
    When method POST
    Then status 201

  @Checkout
  Scenario: Checkout item
    * def checkOutRequest = read('classpath:domain/mod-patron-blocks/features/samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

  @PostItemAndCheckout
  Scenario: Create item and checkout
    * def itemBarcode = random(10000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

  @PostItemAndCheckoutAndRecall
  Scenario: Create item, checkout and recall


