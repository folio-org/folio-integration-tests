Feature: Automated patron blocks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def patronGroupId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def materialTypeId = call uuid1
    * callonce read('util/createGroupAndUser.feature') { patronGroupId: '#(patronGroupId)', userId: '#(userId)', userBarcode: '#(userBarcode)' }
    * def createInstanceResult = callonce read('util/initData.feature@Init') {materialTypeId: '#(materialTypeId)'}
    * def response = createInstanceResult.response
    # * def hrid = response.hrid
    * def holdingsRecordId = response.id
    * def servicePointId = call uuid1
    * def patronBlockConditionsMessages = read('util/messages-text.json')
    * def maxNumberOfOverdueRecallConditionId = 'e5b45031-a202-4abb-917b-e1df9346fe2c'
    * def maxNumberOfItemsChargedOutConditionId = '3d7c52dc-c732-4223-8bf8-e5917801386f'
    * def createAndCheckOutItem = function() { karate.call('util/createItem.feature', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId});}

  Scenario: Borrowing block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * def itemBarcode = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: patronBlockConditionsMessages.maxNumOfItemsChargedOut}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut, createAndCheckOutItem)
    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    * def item = read('samples/item-entity.json')
    * item.holdingsRecordId = holdingsRecordId
    * item.materialType = {id: materialTypeId}

    Given path 'inventory/items'
    And request item
    When method POST
    Then status 201

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422

  Scenario: All blocks exist when 'Maximum number of overdue recalls' is reached
    * def maxNumberOfOverdueRecalls = 3
    * def limitId = call uuid1
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: patronBlockConditionsMessages.maxNumberOfOverdueRecalls}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: 3}

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
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items aged to lost
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
