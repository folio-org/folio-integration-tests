Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * def dcbTransactionId = '123456891'
    * def itemBarcode = 'newdcb123'

    * def patronId = 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2'
    * def patronName = 'patronName'

    * def defaultPermanentLocationId = '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
    * def instanceId = 'ea614654-73d8-11ee-b962-0242ac120002'

  @CreateInstance
  Scenario: Create Instance
    * def intInstanceTypeId = 'eb829260-73d1-11ee-b962-0242ac120002'
    * def contributorNameTypeId = 'f2cedf06-73d1-11ee-b962-0242ac120002'
    * def instanceTypeEntityRequest = read('samples/instance/instance-type-entity-request.json')
    * instanceTypeEntityRequest.id = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source

    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/instance/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = contributorNameTypeEntityRequest.name
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * call pause 5000
    * def instanceEntityRequest = read('samples/instance/instance-entity-request.json')
    * instanceEntityRequest.instanceTypeId = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceEntityRequest.id = karate.get('extInstanceId', instanceId)
    Given path 'inventory/instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @CreateHoldings
  Scenario: Create Holdings
    Given path 'holdings-storage/holdings'
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And request
          """
          {
              "instanceId": "#(instanceId)",
              "permanentLocationId": "#(permanentLocationId)"
          }
          """
    When method POST
    Then status 201
    And def holdingsId = response.id
    And def hrid = response.hrid
    And def effectiveLocationId = response.effectiveLocationId

  Scenario: create item
    Given path 'inventory/items'
    And def permanentLocationId = karate.get('permanentLocationId', defaultPermanentLocationId)
    And def barcode = karate.get('barcode', 'newdcb123')
    And request
          """
          {
              "holdingsRecordId": "##(holdingsId)",
              "barcode": "##(barcode)",
              "status": {
                "name": "Available"
              },
              "materialType": {
                "id": "d9acad2f-2aac-4b48-9097-e6ab85906b25"
              },
              "permanentLoanType": {
                "id": "2e48e713-17f3-4c13-a9f8-23845bb210a4"
              },
              "permanentLocation": {
                "id": "##(permanentLocationId)"
              }
          }
      """
    When method POST
    Then status 201
    And def itemId = response.id
    And def effectiveLocationId = response.effectiveLocation.id

  Scenario: create patronGroup.
    Given path 'groups'
    And request
        """{
              "group": "#(patronName)",
              "desc": "For Testing",
              "expirationOffsetInDays": "60",
              "id": "#(patronId)"
            }
          """
    When method POST
    Then status 201

  Scenario: Create DCB transaction
    Given path '/transactions/' + dcbTransactionId
    And request
          """{
              "item": {
                "id": "e2325f58-e757-43c6-a761-de634f075f71",
                "title": "Test",
                "barcode": "#(itemBarcode)",
                "pickupLocation": "Datalogisk Institut",
                "materialType": "book",
                "lendingLibraryCode": "KU"
              },
              "patron": {
                "id": "#(patronId)",
                "group": "#(patronName)",
                "barcode": "11111",
                "borrowingLibraryCode": "E"
              },
              "pickup": {
                "servicePointId": "0da8c1e4-1c1f-4dd9-b189-70ba978b7d95",
                "servicePointName": "TestServicePointCode6",
                "libraryName": "TestLibraryName6",
                "libraryCode": "TestLibraryCode6"
              },
              "role": "LENDER"
            }
          """
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

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('samples/service-point-entity-request.json')
    * servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PutServicePointNonPickupLocation
  Scenario: update service point
    * def id = call uuid1
    * def servicePoint = read('samples/service-point-entity-request.json')
    * servicePoint.id = karate.get('extServicePointId', servicePointId)
    * servicePoint.name = servicePoint.name + ' ' + random_string()
    * servicePoint.code = servicePoint.code + ' ' + random_string()
    * servicePoint.pickupLocation = false
    * remove servicePoint.holdShelfExpiryPeriod
    Given path 'service-points', servicePoint.id
    And request servicePoint
    When method PUT
    Then status 204

