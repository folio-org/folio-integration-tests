Feature: Automated patron blocks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def patronGroupId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostGroup') { patronGroupId: '#(patronGroupId)' }

    * def postUserResult = call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { patronGroupId: '#(patronGroupId)' }
    * def postUserResponse = postUserResult.response
    * def userId = postUserResponse.id
    * def userBarcode = postUserResponse.barcode
    * def materialTypeId = callonce uuid1
    * def declaredLostDateTime = '2020-01-01'
    * def dueDate = '2021-07-07'
    * def createInstanceResult = callonce read('util/initData.feature@Init') {materialTypeId: '#(materialTypeId)'}
    * def response = createInstanceResult.response
    * def holdingsRecordId = response.id
    * def servicePoint = read('samples/service-point-entity.json')
    * def servicePointId = servicePoint.id
    * def createFineOwner = callonce read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostOwner') { servicePointId: '#(servicePointId)'}
    * def fineOwnerId = createFineOwner.response.id
    * def patronBlockConditionsMessages = read('util/messages-text.json')
    * def maxNumberOfOverdueRecallConditionId = 'e5b45031-a202-4abb-917b-e1df9346fe2c'
    * def maxNumberOfItemsChargedOutConditionId = '3d7c52dc-c732-4223-8bf8-e5917801386f'
    * def maxNumberOfLostItemsConditionId = '72b67965-5b73-4840-bc0b-be8f3f6e047e'
    * def maxNumberOfOverdueItemsConditionId = '584fbd4f-6a34-4730-a6ca-73a6a6a9d845'
    * def createAndCheckOutItem = function() { var itemBarcode = random(100000); karate.call('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckout', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId});}
    * def createAndDeclareLostItem = function() { var itemBarcode = random(100000); karate.call('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckoutAndDeclareLost', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, declaredLostDateTime: declaredLostDateTime});}
    * def createAndOverdueItem = function() { var itemBarcode = random(100000); karate.call('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckoutAndMakeOverdue', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, dueDate: dueDate});}


  Scenario: Borrowing block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * def itemBarcode = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: patronBlockConditionsMessages.maxNumOfItemsChargedOut}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut, createAndCheckOutItem)

    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422

  Scenario: Renewing block exists when 'Max number of items charged out' limit is reached
    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: patronBlockConditionsMessages.maxNumOfItemsChargedOut}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut - 1, createAndCheckOutItem)

    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut - 1)', limitId: '#(limitId)'}

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422

  Scenario: Requesting block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: patronBlockConditionsMessages.maxNumOfItemsChargedOut}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut, createAndCheckOutItem)

    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut - 1)', limitId: '#(limitId)'}

    * def itemBarcode = random(100000)
    * def itemRequest = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/request-entity.json')
    * requestItemRequest.itemId = itemId
    * requestItemRequest.requesterId = userId

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422

  Scenario: All blocks exist when 'Maximum number of overdue recalls' is reached
    * def maxNumberOfOverdueRecalls = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: patronBlockConditionsMessages.maxNumberOfOverdueRecalls}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: 3}

  Scenario: Borrowing block exists when 'Max number of lost items' limit is reached'
    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items', pbcMessage: patronBlockConditionsMessages.maxNumberOfLostItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422


  Scenario: Renewing block exists when 'Max number of lost items' limit is reached
    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items', pbcMessage: patronBlockConditionsMessages.maxNumberOfLostItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422

  Scenario: Requesting block exists when 'Max number of lost items' limit is reached
    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items', pbcMessage: patronBlockConditionsMessages.maxNumberOfLostItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def itemBarcode = random(100000)
    * def itemRequest = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/request-entity.json')
    * requestItemRequest.itemId = itemId
    * requestItemRequest.requesterId = userId

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422

  Scenario: Borrowing block exists when 'Max number of overdue items' limit is reached
    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items', pbcMessage: patronBlockConditionsMessages.maxNumberOfOverdueItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422

  Scenario: Renewing block exists when 'Max number of overdue items' limit is reached
    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}

    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items', pbcMessage: patronBlockConditionsMessages.maxNumberOfOverdueItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422

  Scenario: Requesting block exists when 'Max number of overdue items' limit is reached
    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items', pbcMessage: patronBlockConditionsMessages.maxNumberOfOverdueItems}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def itemBarcode = random(100000)
    * def itemRequest = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/request-entity.json')
    * requestItemRequest.itemId = itemId
    * requestItemRequest.requesterId = userId

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422

  @Undefined
  Scenario: Should return 'Bad request' error when called with invalid user ID
    * print 'undefined'

  @Undefined
  Scenario: No blocks when user summary does not exist
    * print 'undefined'

  @Undefined
  Scenario: No blocks when no limits exist for patron group
    * print 'undefined'

  # Max number of items charged out

  @Undefined
  Scenario: No blocks when 'Max number of items charged out' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of items charged out' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is exceeded and all limits exist
    * print 'undefined'

  # Max number of lost items - declared lost

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items declared lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items declared lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items declared lost and all limits exist
    * print 'undefined'

  # Max number of lost items - aged to lost

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items aged to lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items aged to lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items aged to lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items aged to lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items aged to lost and all limits exist
    * print 'undefined'
    
  # Max number of overdue items

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue items' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue items' limit is exceeded and all limits exist
    * print 'undefined'
    
  # Max number of overdue recalls

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue recalls' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue recalls' limit is exceeded and all limits exist
    * print 'undefined'

  # Recall overdue by maximum number of days

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Recall overdue by maximum number of days' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Recall overdue by maximum number of days' limit is exceeded and all limits exist
    * print 'undefined'
    
  # Max outstanding fee/fine balance

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max outstanding fee/fine balance' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max outstanding fee/fine balance' limit is exceeded and all limits exist
    * print 'undefined'

  # All limits

  @Undefined
  Scenario: Everything is blocked when all limits are exceeded
    * print 'undefined'

  @Undefined
  Scenario: Nothing is blocked when all limits are exceeded for items claimed returned
    * print 'undefined'

  # Other

  @Undefined
  Scenario: Updated values from condition are passed to response
    * print 'undefined'

  @Undefined
  Scenario: No block when loan is not overdue
    * print 'undefined'

  @Undefined
  Scenario: No block when loan is not overdue because of grace period
    * print 'undefined'

  @Undefined
  Scenario: Block when loan is overdue
    * print 'undefined'

  @Undefined
  Scenario: Block when loan is overdue and grace period exists
    * print 'undefined'

  @Undefined
  Scenario: Items declared lost and aged to lost are combined for max number of lost items block
    * print 'undefined'
