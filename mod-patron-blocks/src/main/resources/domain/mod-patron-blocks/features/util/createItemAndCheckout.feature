Feature: Create item and checkout

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def permanentLoanTypeId = call uuid1
    * def temporaryLoanTypeId = call uuid1
    * def temporaryLocationId = call uuid1
    * def itemId = call uuid1

  @PostItem
  Scenario: Create item
    * def itemId = call uuid1
    * def item = read('classpath:domain/mod-patron-blocks/features/samples/item-entity.json')
    * item.holdingsRecordId = holdingsRecordId
    * item.id = itemId
    * item.materialType = {id: materialTypeId}
    * item.barcode = itemBarcode

    Given path 'inventory/items'
    And request item
    When method POST
    Then status 201

  @Checkout
  Scenario: Checkout item in circulation
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
    # * def itemBarcode = random(10000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

  @PostItemAndCheckoutAndRecall
  Scenario: Create item, create check out event and recall
    * def itemBarcode = random(10000)
    * def postItemResult = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckout') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = postItemResult.response.item.id
    #* call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
#    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)', userBarcode:'#(userBarcode)', servicePointId: '#(servicePointId)' }
#    * def postItemResultResponse = postItemResult.response
#    * def itemId = postItemResultResponse.id
#    * def loanId = call uuid1
#    * def loanDate = Java.type("java.time.LocalDateTime").now().minusMinutes(7) + ''
#    * def action = 'checkedout'

    * def recallRequest = read('samples/recall-request.json')
    * set recallRequest.id = call uuid1
    * set recallRequest.itemId = itemId

    Given path 'circulation/requests'
    And request recallRequest
    When method POST
    Then status 201
#
#    * def loanDueDateChangedEvent = read('classpath:domain/mod-patron-blocks/features/samples/loan-due-date-changed-event-entity.json')
#
#    Given path 'automated-patron-blocks/handlers/loan-due-date-changed'
#    And request loanDueDateChangedEvent
#    When method POST
#    Then status 204



