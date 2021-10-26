Feature: Fee/fine accounts tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def mockLoanId = call uuid1
    * def userId = call uuid1
    * def feefineId = call uuid1
    * def ownerId = call uuid1
    * def accountId = call uuid1
    * def accountId2 = call uuid1
    * def servicePointId = call uuid1

  # CRUD

  Scenario: Create an account
    * def requestEntity = read('samples/account-request-entity.json')

    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201
    And match response == { amount: #present, contributors: #present, metadata: #present, feeFineId: #present, id: #present, ownerId: #present, userId: #present, remaining: #present, paymentStatus: #present, status: #present }
    And match $.userId == userId
    And match $.feeFineId == feefineId
    And match $.ownerId == ownerId
    And match $.id == accountId
    And match $.amount == 100
    And match $.remaining == 100

  Scenario: Get a list of accounts
    Given path 'accounts'
    When method GET
    Then status 200
    And match response == { accounts: #present, totalRecords: #present, resultInfo: #present }

  Scenario: Get an account by ID
    * def requestEntity = read('samples/account-request-entity.json')

    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'accounts', accountId
    When method GET
    Then status 200
    And match response == { amount: #present, contributors: #present, metadata: #present, feeFineId: #present, id: #present, ownerId: #present, userId: #present, remaining: #present, paymentStatus: #present, status: #present }
    And match response.id == accountId

  Scenario: Update an account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'accounts', accountId
    When method GET
    Then status 200
    And match response.remaining == 100

    * requestEntity.remaining = 3
    Given path 'accounts', accountId
    And request requestEntity
    When method PUT
    Then status 204

    Given path 'accounts', accountId
    When method GET
    Then status 200
    And match response.remaining == 3

  Scenario: Delete an account
    * def requestEntity = read('samples/account-request-entity.json')

    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'accounts', accountId
    When method GET
    Then status 200

    Given path 'accounts', accountId
    When method DELETE
    Then status 204

    Given path 'accounts', accountId
    When method GET
    Then status 404

  Scenario: Can not create an account without required referenced entity IDs
    * def requestEntity = read('samples/account-request-entity.json')
    * def expectedErrMsg = "must not be null"
    * requestEntity.id = null

    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  Scenario: Can not create an account with invalid UUID for any of the referenced entities
    * def requestEntity = read('samples/account-request-entity.json')
    * requestEntity.id = "invalid-uuid"
    * def expectedErrMsg = "must match \"^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[1-5][a-fA-F0-9]{3}-[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$\""

    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 422
    And match $.errors[0].message == expectedErrMsg

  # Check actions

  Scenario: "check-pay" amount should be allowed when it doesn't exceed the remaining amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 30
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: "check-pay" amount should not be allowed when it exceeds the remaining amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 130
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Requested amount exceeds remaining amount'

  Scenario: "check-pay" amount should not be allowed when it is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = -30
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Amount must be positive'

  Scenario: "check-pay" amount should not be allowed when it is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 0
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Amount must be positive'

  Scenario: "check-pay" amount should be numeric
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = "literal amount"
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Invalid amount entered'

  Scenario: "check-pay" should not fail for nonexistent account
    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 10

    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

  Scenario: "check-pay" should not be allowed for a closed account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 10
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Fee/fine is already closed'

  Scenario: "check-pay" should handle long decimals correctly
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'check-pay'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: "check-transfer" should not fail for nonexistent account
    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20

    Given path 'accounts', accountId, 'check-transfer'
    And request checkRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

  Scenario: "check-transfer" should not be allowed for a closed account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20
    Given path 'accounts', accountId, 'check-transfer'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Fee/fine is already closed'

  Scenario: "check-waive" amount should not be allowed when it exceeds the remaining amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 130
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Requested amount exceeds remaining amount'

  Scenario: "check-waive" amount should not be allowed when it is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = -30
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Amount must be positive'

  Scenario: "check-waive" amount should not be allowed when it is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 0
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Amount must be positive'

  Scenario: "check-waive" amount should be numeric
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = "literal amount"
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Invalid amount entered'

  Scenario: "check-waive" should not fail for nonexistent account
    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20

    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

  Scenario: "check-waive" should not be allowed for a closed account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == 'Fee/fine is already closed'

  Scenario: "check-waive" should handle long decimals correctly
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: Failed "check-waive" return the initial requested amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 200
    Given path 'accounts', accountId, 'check-waive'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.amount == '200'

  Scenario: "check-refund" amount should be allowed when it doesn't exceed the remaining amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 30
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: "check-refund" amount should not be allowed when it exceeds the remaining amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 130
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == "Refund amount must be greater than zero and less than or equal to Selected amount"

  Scenario: "check-refund" amount should not be allowed when it is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = -30
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

  Scenario: "check-refund" amount should not be allowed when it is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 0
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

  Scenario: "check-refund" amount should be numeric
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = "literal amount"
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.errorMessage == "Invalid amount entered"

  Scenario: "check-refund" should not fail for nonexistent account
    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = "literal amount"
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

  Scenario: "check-refund" should be allowed for a closed account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 90
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: "check-refund" should handle long decimals correctly
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 200
    And match $.accountId == accountId
    And match $.allowed == true

  Scenario: Failed "check-refund" return the initial requested amount
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def checkRequestEntity = read('samples/check-action-request-entity.json')
    * checkRequestEntity.amount = 200
    Given path 'accounts', accountId, 'check-refund'
    And request checkRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.allowed == false
    And match $.amount == '200'

  # Bulk check actions

  Scenario: Bulk check for pay, waive and transfer actions should be allowed when amount not exceeded
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = 70
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 200
    And match $.remainingAmount == "90.00"
    And match $.amount == "70"
    And match $.allowed == true

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = 70
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 200
    And match $.remainingAmount == "90.00"
    And match $.amount == "70"
    And match $.allowed == true

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = 70
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 200
    And match $.remainingAmount == "90.00"
    And match $.amount == "70"
    And match $.allowed == true

  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is exceeded
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = 170
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 422
    And match $.amount == "170"
    And match $.allowed == false
    And match $.errorMessage == 'Requested amount exceeds remaining amount'

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = 170
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 422
    And match $.amount == "170"
    And match $.allowed == false
    And match $.errorMessage == 'Requested amount exceeds remaining amount'

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = 170
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 422
    And match $.amount == "170"
    And match $.allowed == false
    And match $.errorMessage == 'Requested amount exceeds remaining amount'

  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = -30
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 422
    And match $.amount == "-30"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = -30
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 422
    And match $.amount == "-30"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = -30
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 422
    And match $.amount == "-30"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = 0
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 422
    And match $.amount == "0"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = 0
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 422
    And match $.amount == "0"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = 0
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 422
    And match $.amount == "0"
    And match $.allowed == false
    And match $.errorMessage == "Amount must be positive"

  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is not numeric
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = "literal amount"
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 422
    And match $.amount == "literal amount"
    And match $.allowed == false
    And match $.errorMessage == "Invalid amount entered"

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = "literal amount"
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 422
    And match $.amount == "literal amount"
    And match $.allowed == false
    And match $.errorMessage == "Invalid amount entered"

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = "literal amount"
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 422
    And match $.amount == "literal amount"
    And match $.allowed == false
    And match $.errorMessage == "Invalid amount entered"

  Scenario: Bulk check for pay, waive and transfer actions should succeed for nonexistent account
    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = 30
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 404

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = 30
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 404

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = 30
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 404

  Scenario: Bulk check for pay, waive and transfer actions should not be allowed for closed account
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def requestBulkPayEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkPayEntity.amount = 70
    Given path 'accounts-bulk', 'check-pay'
    And request requestBulkPayEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.errorMessage == "Fee/fine is already closed"

    * def requestBulkWaiveEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkWaiveEntity.amount = 70
    Given path 'accounts-bulk', 'check-waive'
    And request requestBulkWaiveEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.errorMessage == "Fee/fine is already closed"

    * def requestBulkTransferEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkTransferEntity.amount = 70
    Given path 'accounts-bulk', 'check-transfer'
    And request requestBulkTransferEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.errorMessage == "Fee/fine is already closed"

  # Bulk check for refund action

  Scenario: Bulk refund should be allowed when amount is not exceeded
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = 50
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 200
    And match $.allowed == true
    And match $.amount == "50"

  Scenario: Bulk refund should not be allowed when amount is exceeded
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = 160
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.amount == "160"
    And match $.errorMessage == "Refund amount must be greater than zero and less than or equal to Selected amount"

  Scenario: Bulk refund should not be allowed when amount is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = -30
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.amount == "-30"
    And match $.errorMessage == "Amount must be positive"

  Scenario: Bulk refund should not be allowed when amount is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = 0
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.amount == "0"
    And match $.errorMessage == "Amount must be positive"

  Scenario: Bulk refund should not be allowed when amount is not numeric
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = "literal amount"
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 422
    And match $.allowed == false
    And match $.amount == "literal amount"
    And match $.errorMessage == "Invalid amount entered"

  Scenario: Bulk refund should be allowed when account is nonexistent
    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = 30

    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 404

  Scenario: Bulk refund should return correct remaining amount with similar account IDs
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * requestEntity.id = accountId2
    * requestEntity.amount = 60
    * requestEntity.remaining = 60
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 90
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 55
    Given path 'accounts', accountId2, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def requestBulkRefundEntity = read('samples/account-bulk-request-entity.json')
    * requestBulkRefundEntity.amount = 30
    * requestBulkRefundEntity.accountIds = [ accountId, accountId ]
    Given path 'accounts-bulk', 'check-refund'
    And request requestBulkRefundEntity
    When method POST
    Then status 200
    And match $.allowed == true
    And match $.amount == "30"

#   Account pay, waive and transfer actions

  Scenario: Pay, waive and transfer actions should return 404 when account doesn't exist
    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 30
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = 30
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 30
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 404
    And match response == 'Fee/fine ID ' + accountId + ' not found'

  Scenario: Pay, waive and transfer actions should return 422 when amount is negative
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = -30
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "-30"
    And match $.errorMessage == "Amount must be positive"

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = -30
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "-30"
    And match $.errorMessage == "Amount must be positive"

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = -30
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "-30"
    And match $.errorMessage == "Amount must be positive"

  Scenario: Pay, waive and transfer actions should return 422 when amount is zero
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 0
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "0"
    And match $.errorMessage == "Amount must be positive"

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = 0
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "0"
    And match $.errorMessage == "Amount must be positive"

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 0
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "0"
    And match $.errorMessage == "Amount must be positive"

  Scenario: Pay, waive and transfer actions should return 422 when amount is invalid
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = "invalid amount"
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "invalid amount"
    And match $.errorMessage == "Invalid amount entered"

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = "invalid amount"
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "invalid amount"
    And match $.errorMessage == "Invalid amount entered"

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = "invalid amount"
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "invalid amount"
    And match $.errorMessage == "Invalid amount entered"

  Scenario: Pay, waive and transfer actions should return 422 when account is closed
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 30
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "30"
    And match $.errorMessage == "Fee/fine is already closed"

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = 30
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "30"
    And match $.errorMessage == "Fee/fine is already closed"

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 30
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 422
    And match $.accountId == accountId
    And match $.amount == "30"
    And match $.errorMessage == "Fee/fine is already closed"

  Scenario: Pay, waive and transfer actions should handle long decimals correctly
    * def requestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request requestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 201

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 20.444444444444444
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 201
