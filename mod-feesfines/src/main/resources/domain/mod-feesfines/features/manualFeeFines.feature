Feature: manual fee/fines

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def ownerId = call uuid1
    * def feefineId = call uuid1
    * def paymentId = call uuid1
    * def userId = call uuid1
    * def accountId = call uuid1
    * def transferId = call uuid1
    * def servicePointId = call uuid1

  Scenario: After a new manual fee/fine is created, able to pay it immediately
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Paid fully'


  Scenario: After a new manual fee/fine is created, able to pay it as a separate action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 50
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 50
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Paid partially'

    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Paid fully'


  Scenario: After a new manual fee/fine is created, able to transfer it as a separate action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def transferRequestEntity = read('samples/transfer-request-entity.json')
    Given path 'transfers'
    And request transferRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 50
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 50
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Transferred partially'

    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Transferred fully'


  Scenario: After a new manual fee/fine is created, able to waive it as a separate action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def waiveRequestEntity = read('samples/waive-reasons-request-entity.json')
    Given path 'waives'
    And request waiveRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def waiveRequestEntity = read('samples/pay-request-entity.json')
    * waiveRequestEntity.amount = 50
    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 50
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Waived partially'

    Given path 'accounts', accountId, 'waive'
    And request waiveRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 50
    And match response.feefineactions[0].typeAction == 'Waived fully'


  Scenario: After a new manual fee/fine is created, able to cancel it as an error as a separate action
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def cancelRequestEntity = read('samples/cancel-request-entity.json')
    Given path 'accounts', accountId, 'cancel'
    And request cancelRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Cancelled as error'


  Scenario: After a manual fee/fine has been paid, able to refund the amount paid to patron
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def payRequestEntity = read('samples/pay-request-entity.json')
    * payRequestEntity.amount = 100
    Given path 'accounts', accountId, 'pay'
    And request payRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Paid fully'

    Given path 'accounts', accountId, 'refund'
    And request payRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Credited fully'
    And match response.feefineactions[1].balance == 100
    And match response.feefineactions[1].amountAction == 100
    And match response.feefineactions[1].typeAction == 'Refunded fully'


  Scenario: After a manual fee/fine has been transferred, able to refund the amount transferred to the appropriate transfer account
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def paymentRequestEntity = read('samples/payment-request-entity.json')
    Given path 'payments'
    And request paymentRequestEntity
    When method POST
    Then status 201

    * def transferRequestEntity = read('samples/transfer-request-entity.json')
    Given path 'transfers'
    And request transferRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201

    * def accountRequestEntity = read('samples/account-request-entity.json')
    Given path 'accounts'
    And request accountRequestEntity
    When method POST
    Then status 201

    * def transferRequestEntity = read('samples/pay-request-entity.json')
    * transferRequestEntity.amount = 100
    Given path 'accounts', accountId, 'transfer'
    And request transferRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Transferred fully'

    Given path 'accounts', accountId, 'refund'
    And request transferRequestEntity
    When method POST
    Then status 201
    And match response.accountId == accountId
    And match response.feefineactions[0].balance == 0
    And match response.feefineactions[0].amountAction == 100
    And match response.feefineactions[0].typeAction == 'Credited fully'
    And match response.feefineactions[1].balance == 100
    And match response.feefineactions[1].amountAction == 100
    And match response.feefineactions[1].typeAction == 'Refunded fully'