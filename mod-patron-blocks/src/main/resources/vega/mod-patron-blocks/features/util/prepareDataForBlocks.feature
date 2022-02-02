Feature: Create item and checkout

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def permanentLoanTypeId = call uuid1
    * def temporaryLoanTypeId = call uuid1
    * def temporaryLocationId = call uuid1

  @Checkout
  Scenario: Checkout item in circulation
    * def checkOutRequest = read('classpath:vega/mod-patron-blocks/features/samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

  @PostItemAndCheckout
  Scenario: Create item and checkout
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

  @PostOwner
  Scenario: Post owner
    * def owner = read('classpath:vega/mod-patron-blocks/features/samples/owner-entity.json')

    Given path 'owners'
    And request owner
    When method POST
    Then status 201

  @DeclareLost
  Scenario: Declare item lost
    * def declareLostRequest = read('classpath:vega/mod-patron-blocks/features/samples/declare-item-lost-request.json')
    * declareLostRequest.servicePointId = servicePointId
    * declareLostRequest.declaredLostDateTime = declaredLostDateTime

    Given path 'circulation/loans/' + loanId + '/declare-item-lost'
    And request declareLostRequest
    When method POST
    Then status 204

  @PostItemAndCheckoutAndDeclareLost
  Scenario: Create item, checkout and declare lost
    * def itemBarcode = random(10000)
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def loan = call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
    * def loanId = loan.response.id;
    * call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@DeclareLost') { declaredLostDateTime: '#(declaredLostDateTime)', servicePointId: '#(servicePointId)', loanId: '#(loanId)'}

  @PostItemAndCheckoutAndMakeOverdue
  Scenario: Create item, checkout and make overdue
    * def itemBarcode = random(10000)
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def loan = call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') { userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
    * def loanBody = loan.response
    * loanBody.dueDate = dueDate

    Given path 'circulation/loans/' + loanBody.id
    And request loanBody
    When method PUT
    Then status 204

  @PostItemAndCheckoutAndRecall
  Scenario: Create item, create check out event and recall
    * def itemBarcode = random(10000)
    * def postItemResult = call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckout') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)', userBarcode:'#(userBarcode)', servicePointId: '#(servicePointId)'}
    * def loanBody = postItemResult.response
    * def itemId = loanBody.item.id

    * def recallRequest = read('samples/recall-request-entity.json')
    * set recallRequest.id = call uuid1
    * set recallRequest.itemId = itemId

    Given path 'circulation/requests'
    And request recallRequest
    When method POST
    Then status 201

    * loanBody.dueDate = dueDateInThePast
    * loanBody.dueDateChangedByRecall = true

    Given path 'circulation/loans/' + loanBody.id
    And request loanBody
    When method PUT
    Then status 204

    Given path 'user-summary/' + userId
    When method GET
    Then status 200

  @ReachMaximumFeeFineBalance
  Scenario: reach maximum fee fine balance
    * def itemBarcode = random(1000000000)
    * def postItemResult = call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckout') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)', userBarcode:'#(userBarcode)', servicePointId: '#(servicePointId)'}
    * def response = postItemResult.response
    * def itemId = response.item.id
    * def loanId = response.id

    * def account = read('samples/account-entity.json')
    * account.amount = maximum + 1
    * account.remaining = maximum + 1
    * set account.feeFineId = call uuid1
    * set account.id = call uuid1

    Given path 'accounts'
    And request account
    When method POST
    Then status 201


  @ReachRecallOverdueByMaximumNumberOfDays
  Scenario: reach recall overdue by maximum number of days
    * def itemBarcode = random(10000)
    * def postItemResult = call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckout') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)', userBarcode:'#(userBarcode)', servicePointId: '#(servicePointId)'}
    * def loanBody = postItemResult.response
    * def itemId = loanBody.item.id

    * def recallRequest = read('samples/recall-request-entity.json')
    * set recallRequest.id = call uuid1

    Given path 'circulation/requests'
    And request recallRequest
    When method POST
    Then status 201

    * loanBody.dueDate = Java.type('java.time.LocalDate').now().minusDays(maximum)
    * loanBody.dueDateChangedByRecall = true

    Given path 'circulation/loans/' + loanBody.id
    And request loanBody
    When method PUT
    Then status 204
