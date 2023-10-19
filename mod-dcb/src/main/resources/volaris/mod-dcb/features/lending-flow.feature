Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  Scenario: Item check-in at lending library. Update transaction status from CREATED to OPEN.

    * def dcbTransactionId = '123456891'
    * def patronId = util1.uuid1()
    * def patronName = util2.random_string()

    @PostPatronGroupAndUser
    Scenario: Create PatronGroup.
      * def createPatronGroupRequest = read('samples/PatronGroup/create-patronGroup-request.json')

      Given path 'groups'
      And request createPatronGroupRequest
      When method POST
      Then status 201

    Scenario: Create DCB Transaction. Status at the beginning is CREATED.
        Given path '/transactions/' + dcbTransactionId
        And request
          """
          {
            "item": {
              "id": "e2325f58-e757-43c6-a761-de634f075f71",
              "title": "Test",
              "barcode": "newdcb123",
              "pickupLocation": "Datalogisk Institut",
              "materialType": "book",
              "lendingLibraryCode": "KU"
          },
            "patron": {
                "id": #(patronId)
                "group": #(patronName)
                "barcode": "11111",
                "borrowingLibraryCode": "E"
           },
          "role": "LENDER"
          }
          """
        When method POST
        Then status 201

    Scenario: GET Transaction status by id.
      Given path '/transactions/' + dcbTransactionId + '/status'
      When method GET
      Then status 200
      And match response.status == 'CLOSED'

  @CheckInItem
  Scenario: check in item by barcode
    * def checkInId = call uuid
    * def intCheckInDate = call read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')

    * def checkInRequest = read('classpath:vega/mod-circulation/features/samples/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkInRequest.checkInDate = karate.get('extCheckInDate', intCheckInDate)
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.loan.action == 'checkedin'
    And match $.loan.status.name == 'Closed'

    Scenario: Update transaction status CREATED-OPEN.
      Given path '/transactions/' + dcbTransactionId
      And request
          """
          {
            "status": "OPEN"
          }
          """
      When method PUT
      Then status 200

    Scenario: GET Transaction status by id. Should be OPEN.
      Given path '/transactions/' + dcbTransactionId + '/status'
      When method GET
      Then status 200
      And match response.status == 'CLOSED'


