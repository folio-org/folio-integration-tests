Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * def dcbTransactionId = '123456891'
    * def itemBarcode = 'newdcb123'

  Scenario: Item check-in at lending library. Update transaction status from CREATED to OPEN.

    @PostPatronGroupAndUser
    Scenario: create patronGroup.
      * def createPatronGroupRequest = read('samples/patron/create-patronGroup-request.json')
      Given path 'groups'
      And request createPatronGroupRequest
      When method POST
      Then status 201

    Scenario: create DCB transaction. Status at the beginning is CREATED.
      * def createDCBTransactionRequest = read('samples/transaction/create-dcb-transaction.json')
      Given path '/transactions/' + dcbTransactionId
      And request createDCBTransactionRequest
      When method POST
      Then status 201

    Scenario: get transaction status by id.
      Given path '/transactions/' + dcbTransactionId + '/status'
      When method GET
      Then status 200
      And match response.status == 'CREATED'

    @CheckInItem
    Scenario: check-in item by barcode
    * def checkInId = call uuid
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkInRequest.checkInDate = karate.get('extCheckInDate', intCheckInDate)
    * def num_records = $.totalRecords

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'In transit'
    And call pause 5000

    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def beforeLastAction = get[0] $.logRecords[-1:].action
    And match beforeLastAction == 'Checked in'

    Scenario: update DCB transaction status CREATED-OPEN.
      * def updateDCBTransactionStatusRequest = read('samples/DCBTransaction/update-dcb-transaction.json')
      Given path '/transactions/' + dcbTransactionId
      And request updateDCBTransactionStatusRequest
      When method PUT
      Then status 200

    Scenario: get DCB transaction status by id. Should be OPEN.
      Given path '/transactions/' + dcbTransactionId + '/status'
      When method GET
      Then status 200
      And match response.status == 'CLOSED'

    Scenario: Item delivered to another service point.



