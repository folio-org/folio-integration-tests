Feature: Fee/fine reports tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def ownerId = call uuid1
    * def feefineId = call uuid1
    * def paymentId = call uuid1
    * def userId = call uuid1
    * def accountId = call uuid1
    * def servicePointId = call uuid1

  # Refund report

  Scenario: Refund report should return empty report when refunded after end date
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
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

    Given path 'accounts', accountId, 'refund'
    And request payRequestEntity
    When method POST
    Then status 201

    * def refundReportRequest = read('samples/refund-report-request-entity.json')
    * refundReportRequest.endDate = "2020-01-14"
    Given path 'feefine-reports', 'refund'
    And request refundReportRequest
    When method POST
    Then status 200
    And match response == { reportData: [] }

  Scenario: Refund report should return 422 when request is not valid
    * def expectedErrMsg = "Unrecognized field \"incorrectField\""
    * def refundReportRequest = read('samples/refund-report-request-entity.json')
    * refundReportRequest.incorrectField = 111111111

    Given path 'feefine-reports', 'refund'
    And request refundReportRequest
    When method POST
    Then status 422
    And match $.errors[0].message contains expectedErrMsg

  Scenario: Refund report should return 200 when request is valid
    * def ownerRequestEntity = read('samples/owner-entity-request.json')
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

    Given path 'accounts', accountId, 'refund'
    And request payRequestEntity
    When method POST
    Then status 201

    * def refundReportRequest = read('samples/refund-report-request-entity.json')
    * refundReportRequest.feeFineOwners = [ ownerId ]
    Given path 'feefine-reports', 'refund'
    And request refundReportRequest
    When method POST
    Then status 200
    And match $.reportData[0].patronName == "testuser"

  Scenario: Refund report should return valid result when end date is null
    * def refundReportRequest = read('samples/refund-report-request-entity.json')
    * refundReportRequest.endDate = null
    Given path 'feefine-reports', 'refund'
    And request refundReportRequest
    When method POST
    Then status 200

  Scenario: Refund report should return valid result when start date and end date are null
    * def refundReportRequest = read('samples/refund-report-request-entity.json')
    * refundReportRequest.startDate = null
    * refundReportRequest.endDate = null
    Given path 'feefine-reports', 'refund'
    And request refundReportRequest
    When method POST
    Then status 200
