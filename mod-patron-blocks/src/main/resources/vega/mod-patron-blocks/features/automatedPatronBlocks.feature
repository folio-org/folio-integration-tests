Feature: Automated patron blocks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def patronGroupId = call uuid1
    * def declaredLostDateTime = '2020-01-01'
    * def dueDate = '2021-07-07'
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostGroup') { patronGroupId: '#(patronGroupId)' }
    * def materialTypeId = callonce uuid1
    * def servicePoint = read('samples/service-point-entity.json')
    * def servicePointId = servicePoint.id
    * def createFineOwner = callonce read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostOwner') { servicePointId: '#(servicePointId)'}
    * def fineOwnerId = createFineOwner.response.id
    * def postUserResult = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostUser') { patronGroupId: '#(patronGroupId)' }
    * def postUserResponse = postUserResult.response
    * def userId = postUserResponse.id
    * def userBarcode = postUserResponse.barcode
    * def postDefaultUserResult = callonce read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostUser') { patronGroupId: '#(patronGroupId)' }
    * def postDefaultUserResponse = postDefaultUserResult.response
    * def defaultUserId = postDefaultUserResponse.id
    * def defaultUserBarcode = postDefaultUserResponse.barcode
    * def instance = read('samples/instance-entity.json')
    * def instanceId = instance.id
    * def createInstanceResult = callonce read('util/initData.feature@Init') { materialTypeId: '#(materialTypeId)', servicePointId:'#(servicePointId)' }
    * def response = createInstanceResult.response
    * def holdingsRecordId = response.id
    * def patronBlockConditionsMessages = read('util/messages-text.json')
    * def maxNumberOfOverdueRecallConditionId = 'e5b45031-a202-4abb-917b-e1df9346fe2c'
    * def maxNumberOfItemsChargedOutConditionId = '3d7c52dc-c732-4223-8bf8-e5917801386f'
    * def maxNumberOfLostItemsConditionId = '72b67965-5b73-4840-bc0b-be8f3f6e047e'
    * def maxNumberOfOverdueItemsConditionId = '584fbd4f-6a34-4730-a6ca-73a6a6a9d845'
    * def maxOutstandingFeeFineBalanceConditionId = 'cf7a0d5f-a327-4ca1-aa9e-dc55ec006b8a'
    * def recallOverdueByMaxNumberOfDaysConditionId = '08530ac4-07f2-48e6-9dda-a97bc2bf7053'
    * def createAndCheckOutItem = function() { var itemBarcode = uuid(); karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckout', { servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, itemBarcode: itemBarcode});}
    * def createItemAndCheckOutAndRecall = function() { karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckoutAndRecall', { requesterId: defaultUserId, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, dueDateInThePast:dueDate});}
    * def reachMaximumFeeFineBalance = function(maximum) { karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@ReachMaximumFeeFineBalance', { ownerId:fineOwnerId, userId: userId, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, maximum: maximum});}
    * def recallOverdueByMaxNumberOfDays = function(maximum) { karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@ReachRecallOverdueByMaximumNumberOfDays', { requesterId: defaultUserId, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, maximum: maximum, instanceId: instanceId});}
    * def createAndDeclareLostItem = function() { karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckoutAndDeclareLost', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, declaredLostDateTime: declaredLostDateTime});}
    * def createAndOverdueItem = function() { karate.call('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@PostItemAndCheckoutAndMakeOverdue', { proxyUserBarcode: testUser.barcode, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, dueDate: dueDate});}

  Scenario: Borrowing block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfItemsChargedOut
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut, createAndCheckOutItem)

    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewing block exists when 'Max number of items charged out' limit is reached
    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfItemsChargedOut

    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items',  pbcMessage: '#(errorMessage)',  blockBorrowing: false, blockRenewals: true, blockRequests: false}
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut - 1, createAndCheckOutItem)

    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut - 1)', limitId: '#(limitId)'}

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Requesting block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfItemsChargedOut
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items',  pbcMessage: '#(errorMessage)',  blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut)'}
    * karate.repeat(maxNumOfItemsChargedOut, createAndCheckOutItem)

    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfItemsChargedOutConditionId)', value: '#(maxNumOfItemsChargedOut - 1)', limitId: '#(limitId)'}

    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Max number of lost items' limit is reached'
    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfLostItems
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items',  pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewing block exists when 'Max number of lost items' limit is reached
    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfLostItems
    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items',  pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Requesting block exists when 'Max number of lost items' limit is reached
    * def maxNumberOfLostItems = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfLostItems
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfLostItemsConditionId)', pbcName: 'Max number of lost items',  pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfLostItemsConditionId)', value: '#(maxNumberOfLostItems)'}
    * karate.repeat(maxNumberOfLostItems + 1, createAndDeclareLostItem)

    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Max number of overdue items' limit is reached
    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueItems
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items',  pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def checkOutRequest = read('samples/check-out-request.json')
    * checkOutRequest.userBarcode = userBarcode
    * checkOutRequest.itemBarcode = itemBarcode
    * checkOutRequest.servicePointId = servicePointId

    Given path 'circulation/check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewing block exists when 'Max number of overdue items' limit is reached
    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * call read('classpath:vega/mod-patron-blocks/features/util/prepareDataForBlocks.feature@Checkout') {userBarcode: '#(userBarcode)', itemBarcode: '#(itemBarcode)', servicePointId: '#(servicePointId)'}
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueItems
    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items',  pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def renewRequest = read('samples/renew-by-barcode-request.json')
    * renewRequest.userBarcode = userBarcode
    * renewRequest.itemBarcode = itemBarcode
    * renewRequest.servicePointId = servicePointId

    Given path 'circulation/renew-by-barcode'
    And request renewRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Requesting block exists when 'Max number of overdue items' limit is reached
    * def maxNumberOfOverdueItems = 3
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueItems
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueItemsConditionId)', pbcName: 'Max number of overdue items',  pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') {patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueItemsConditionId)', value: '#(maxNumberOfOverdueItems)'}
    * karate.repeat(maxNumberOfOverdueItems + 1, createAndOverdueItem)

    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(maxNumberOfOverdueRecalls + 1, createItemAndCheckOutAndRecall)
    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { userBarcode: '#(userBarcode)', itemBarcode:'#(itemBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewal block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(maxNumberOfOverdueRecalls + 1, createItemAndCheckOutAndRecall)
    * def itemBarcode = uuid()
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { userBarcode: '#(userBarcode)', itemBarcode:'#(itemBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 201

    Given path 'circulation/renew-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Request block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(maxNumberOfOverdueRecalls + 1, createItemAndCheckOutAndRecall)
    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Maximum outstanding fee/fine balance' limit is reached
    * def maxOutstandingFeeFineBalance = 15
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOutstandingFeeFineBalance
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', pbcName: 'Max outstanding fee fine balance', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', value: '#(maxOutstandingFeeFineBalance)'}
    * call reachMaximumFeeFineBalance maxOutstandingFeeFineBalance
    * def itemBarcode = uuid()
    * def result = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewal block exists when 'Maximum outstanding fee/fine balance' limit is reached
    * def maxOutstandingFeeFineBalance = 15
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOutstandingFeeFineBalance
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', pbcName: 'Max outstanding fee fine balance', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', value: '#(maxOutstandingFeeFineBalance)'}
    * call reachMaximumFeeFineBalance maxOutstandingFeeFineBalance
    * def itemBarcode = uuid()
    * def result = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { userBarcode: '#(userBarcode)', itemBarcode:'#(itemBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 201

    Given path 'circulation/renew-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Request block exists when 'Maximum outstanding fee/fine balance' limit is reached
    * def maxOutstandingFeeFineBalance = 15
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOutstandingFeeFineBalance
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', pbcName: 'Max outstanding fee fine balance', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxOutstandingFeeFineBalanceConditionId)', value: '#(maxOutstandingFeeFineBalance)'}
    * call reachMaximumFeeFineBalance maxOutstandingFeeFineBalance
    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Recall overdue by maximum number of days' limit is reached
    * def maxNumberOfDays = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.recallOverdueByMaxNumberOfDays
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', pbcName: 'Max number of recall overdue days', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', value: '#(maxNumberOfDays)'}
    * call recallOverdueByMaxNumberOfDays maxNumberOfDays
    * def itemBarcode = uuid()
    * def result = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewal block exists when 'Recall overdue by maximum number of days' limit is reached
    * def maxNumberOfDays = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.recallOverdueByMaxNumberOfDays
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', pbcName: 'Max number of recall overdue days', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', value: '#(maxNumberOfDays)'}
    * call recallOverdueByMaxNumberOfDays maxNumberOfDays
    * def itemBarcode = uuid()
    * def result = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request { userBarcode: '#(userBarcode)', itemBarcode:'#(itemBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 201

    Given path 'circulation/renew-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Request block exists when 'Recall overdue by maximum number of days' limit is reached
    * def maxNumberOfDays = 1
    * def limitId = call uuid1
    * def errorMessage = patronBlockConditionsMessages.recallOverdueByMaxNumberOfDays
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', pbcName: 'Max number of recall overdue days', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: false, blockRequests: true }
    * call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(recallOverdueByMaxNumberOfDaysConditionId)', value: '#(maxNumberOfDays)'}
    * call recallOverdueByMaxNumberOfDays maxNumberOfDays
    * def itemBarcode = uuid()
    * def itemRequest = call read('classpath:vega/mod-patron-blocks/features/util/initData.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}
    * def itemId = itemRequest.response.id
    * def requestItemRequest = read('samples/page-request-entity.json')

    Given path 'circulation/requests'
    And request requestItemRequest
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage
