Feature: Automated patron blocks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def patronGroupId = call uuid1
    * def defaultUserId = uuid()
    * def defaultUserBarcode = random(100000)
    * def materialTypeId = call uuid1
    * def servicePointId = call uuid1
    * callonce read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostGroupAndUser') { patronGroupId: '#(patronGroupId)', userId: '#(defaultUserId)', userBarcode: '#(defaultUserBarcode)'}'
    # * def createUser = function(userId, userBarcode) { karate.call('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser', { userId: '#(userId)', userBarcode: '#(userBarcode)' }); }
    # * call createUser userId userBarcode;
    # * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { userId: '#(userId)', userBarcode: '#(userBarcode)' }
    * def createInstanceResult = callonce read('util/initData.feature@Init') { materialTypeId: '#(materialTypeId)', servicePointId:'#(servicePointId)' }
    * def response = createInstanceResult.response
    * def holdingsRecordId = response.id
    * def patronBlockConditionsMessages = read('util/messages-text.json')
    * def maxNumberOfOverdueRecallConditionId = 'e5b45031-a202-4abb-917b-e1df9346fe2c'
    * def maxNumberOfItemsChargedOutConditionId = '3d7c52dc-c732-4223-8bf8-e5917801386f'
    * def createAndCheckOutItem = function() { var itemBarcode = uuid(); karate.call('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckout', { servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId, itemBarcode: itemBarcode});}
    * def createItemAndCheckOutAndRecall = function() { karate.call('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItemAndCheckoutAndRecall', {requesterId: defaultUserId, servicePointId: servicePointId, userBarcode: userBarcode, holdingsRecordId: holdingsRecordId, materialTypeId: materialTypeId});}

  Scenario: Borrowing block exists when 'Max number of items charged out' limit is reached
    * def maxNumOfItemsChargedOut = 3
    * def limitId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def username = random_string()
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfItemsChargedOut
    * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { userId: '#(userId)', userBarcode: '#(userBarcode)', patronGroupId:'#(patronGroupId)' }
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfItemsChargedOutConditionId)', pbcName: 'Max number of charged out items', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
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
    And match response.errors[0].message == errorMessage

  Scenario: Borrowing block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def limitId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def username = random_string()
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { userId: '#(userId)', userBarcode: '#(userBarcode)', patronGroupId:'#(patronGroupId)', username: '#(username)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: true, blockRenewals: false, blockRequests: false }
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(maxNumberOfOverdueRecalls + 1, createItemAndCheckOutAndRecall)
    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    Given path 'circulation/check-out-by-barcode'
    And request {userBarcode: '#(userBarcode)', itemBarcode:'#(itemBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Renewal block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def limitId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def username = random_string()
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { userId: '#(userId)', userBarcode: '#(userBarcode)', patronGroupId:'#(patronGroupId)', username: '#(username)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(maxNumberOfOverdueRecalls + 1, createItemAndCheckOutAndRecall)
    * def itemBarcode = random(100000)
    * def result = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def response = result.response
    * def itemId = response.id
    * def loanDate = Java.type("org.joda.time.DateTime").now() + ''
    * def loanId = call uuid1
    * def action = 'checkedout'

    Given path 'loan-storage/loans'
    And request {itemId: '#(itemId)', loanDate: '#(loanDate)', action: '#(action)', userId: '#(userId)', id: '#(loanId)'}
    When method POST
    Then status 201

    Given path 'circulation/renew-by-barcode'
    And request { itemBarcode: '#(itemBarcode)', userBarcode: '#(userBarcode)', servicePointId: '#(servicePointId)' }
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

  Scenario: Request block exists when 'Maximum number of overdue recalls' limit is reached
    * def maxNumberOfOverdueRecalls = 1
    * def exceedLimit = 2
    * def limitId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def username = random_string()
    * def errorMessage = patronBlockConditionsMessages.maxNumberOfOverdueRecalls
    * call read('classpath:domain/mod-patron-blocks/features/util/createGroupAndUser.feature@PostUser') { userId: '#(userId)', userBarcode: '#(userBarcode)', patronGroupId:'#(patronGroupId)', username: '#(username)'}
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PutPatronBlockConditionById') {pbcId: '#(maxNumberOfOverdueRecallConditionId)', pbcName: 'Max number of overdue recall', pbcMessage: '#(errorMessage)', blockBorrowing: false, blockRenewals: true, blockRequests: false }
    * call read('classpath:domain/mod-patron-blocks/features/util/initData.feature@PostPatronBlocksLimitsByConditionId') { patronGroupId: '#(patronGroupId)', id: '#(limitId)', pbcId: '#(maxNumberOfOverdueRecallConditionId)', value: '#(maxNumberOfOverdueRecalls)'}
    * karate.repeat(exceedLimit, createItemAndCheckOutAndRecall)
    * def itemBarcode = random(100000)
    * def result = call read('classpath:domain/mod-patron-blocks/features/util/createItemAndCheckout.feature@PostItem') { materialTypeId: '#(materialTypeId)', holdingsRecordId: '#(holdingsRecordId)', itemBarcode: '#(itemBarcode)'}

    * def response = result.response
    * def itemId = response.id
    * def loanDate = Java.type("java.time.LocalDateTime").now() + ''
    * def loanId = call uuid1

    Given path 'loan-storage/loans'
    And request {itemId: '#(itemId)', loanDate: '#(loanDate)', action: '#(action)', userId: '#(userId)', id: '#(loanId)'}
    When method POST
    Then status 201

    Given path 'circulation/requests'
    And request {itemId: '#(itemId)',  userId: '#(userId)'}
    When method POST
    Then status 422
    And match response.errors[0].message == errorMessage

