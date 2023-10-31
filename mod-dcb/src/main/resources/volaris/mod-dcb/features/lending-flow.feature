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
    * def instanceId = 'ea614654-73d8-11ee-b962-0242ac120002'
    * def intInstanceTypeId = 'eb829260-73d1-11ee-b962-0242ac120002'
    * def contributorNameTypeId = 'f2cedf06-73d1-11ee-b962-0242ac120002'
    * def institutionId = '8e30bb06-76ff-11ee-b962-0242ac120002'
    * def campusId = 'ae12d634-76ff-11ee-b962-0242ac120002'
    * def libraryId = 'b55e9040-76ff-11ee-b962-0242ac120002'
    * def locationId = 'd8b25bb2-76ff-11ee-b962-0242ac120002'
    * def holdingId = '70cf22e6-779f-11ee-b962-0242ac120002'
    * def checkInId = 'ea1235da-779a-11ee-b962-0242ac120002'

  @CreateInstance
  Scenario: Create Instance
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

  @PostLocation
  Scenario: Create Location
    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name

    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code

    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code

    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('samples/location/location-entity-request.json')
    * locationEntityRequest.name = locationEntityRequest.name
    * locationEntityRequest.code = locationEntityRequest.code

    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201

  @CreateHoldings
  Scenario: Create Holdings
    * def holdingsEntityRequest = read('samples/holdings/holdings-entity-request.json')

    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    And def permanentLocationId = karate.get('permanentLocationId', locationId)
    When method POST
    Then status 201

  Scenario: Create Item
    * def itemRequest = read('samples/item/item-request.json')

    Given path 'inventory/items'
    And request itemRequest
    When method POST
    Then status 201
    And def itemId = response.id
    And def effectiveLocationId = response.effectiveLocation.id

  Scenario: Create PatronGroup
    * def patronGroupRequest = read('samples/patron/create-patronGroup-request.json')

    Given path 'groups'
    And request patronGroupRequest
    When method POST
    Then status 201

  Scenario: Create DCB transaction
    * def createDCBTransactionRequest = read('samples/transaction/create-dcb-transaction.json')

    Given path '/transactions/' + dcbTransactionId
    And request createDCBTransactionRequest
    When method POST
    Then status 201

  Scenario: Get transaction status by id.
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200
    And match response.status == 'CREATED'

  @CheckInItem
  Scenario: Check-in Item by barcode
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

  Scenario: Update DCB transaction status CREATED-OPEN.
    * def updateDCBTransactionStatusRequest = read('samples/DCBTransaction/update-dcb-transaction.json')
    Given path '/transactions/' + dcbTransactionId
    And request updateDCBTransactionStatusRequest
    When method PUT
    Then status 200

  Scenario: Get DCB transaction status by id. Should be OPEN.
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200
    And match response.status == 'CLOSED'

  @PostServicePoint
  Scenario: Create Service point
    * print 'Create Service Point Id'
    * def servicePointEntityRequest = read('samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
    * servicePointEntityRequest.name = servicePointEntityRequest.name
    * servicePointEntityRequest.code = servicePointEntityRequest.code
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PutServicePointNonPickupLocation
  Scenario: Update service point
    * def id = 'f74a04a2-779b-11ee-b962-0242ac120002'
    * def servicePoint = read('samples/service-point/service-point-entity-request.json')
    * servicePoint.id = karate.get('extServicePointId', servicePointId)
    * servicePoint.name = servicePoint.name
    * servicePoint.code = servicePoint.code
    * servicePoint.pickupLocation = false
    * remove servicePoint.holdShelfExpiryPeriod
    Given path 'service-points', servicePoint.id
    And request servicePoint
    When method PUT
    Then status 204

  Scenario: Generate CHECK_OUT event with 'Checked out' 'itemStatusName' and verify number of CHECK_OUT records
    * def num_records = $.totalRecords
    Given path 'circulation/check-out-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcodeCheckInCheckOut)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 201
    * def loanId = $.id
    And match $.item.status.name == 'Checked out'
    And call pause 5000
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Checked out'
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204