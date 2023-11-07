Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

      # load global variables
    * callonce variables

  @PostInstance
  Scenario: Create Instance
    * def instanceTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/instance/instance-type-entity-request.json')
    * instanceTypeEntityRequest.id = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()

    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/instance/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = contributorNameTypeEntityRequest.name + ' ' + random_string()
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('classpath:volaris/mod-dcb/features/samples/instance/instance-entity-request.json')
    * instanceEntityRequest.instanceTypeId = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceEntityRequest.id = karate.get('extInstanceId', instanceId)
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PostLocation
  Scenario: Create Location
    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.id = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name + ' ' + random_string()
    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitCampusEntityRequest.id = karate.get('extCampusId', intCampusId)
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name + ' ' + random_string()
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.id = karate.get('extLibraryId', intLibraryId)
    * locationUnitLibraryEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name + ' ' + random_string()
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('samples/location/location-entity-request.json')
    * locationEntityRequest.id = karate.get('extLocationId', locationId)
    * locationEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationEntityRequest.libraryId = karate.get('extLibraryId', intLibraryId)
    * locationEntityRequest.primaryServicePoint = karate.get('extServicePointId', servicePointId)
    * locationEntityRequest.servicePointIds = [karate.get('extServicePointId', servicePointId)]
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()
    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: Create Holdings
    * def holdingsEntityRequest = read('classpath:volaris/mod-dcb/features/samples/holdings/holdings-entity-request.json')
    * holdingsEntityRequest.id = karate.get('extHoldingsRecordId', holdingId)
    * holdingsEntityRequest.instanceId = karate.get('extInstanceId', instanceId)
    * holdingsEntityRequest.permanentLocationId = karate.get('extLocationId', locationId)
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', materialTypeName)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @PostItem
  Scenario: Create Item
    * def permanentLoanTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = extItemBarcode
    * itemEntityRequest.id = karate.get('extItemId', intItemId)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', intStatusName)
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostGroup
  Scenario: Create Group
    * def groupEntityRequest = read('classpath:volaris/mod-dcb/features/samples/user/group-entity-request.json')
    * groupEntityRequest.id = karate.get('extUserGroupId', intUserGroupId)
    * groupEntityRequest.group = groupEntityRequest.group + ' ' + random_string()
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

  @PostUser
  Scenario: Create User
    * def intUserId = '8b83f6b6-77b3-11ee-b962-0242ac120002'
    * def userEntityRequest = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest.barcode = extUserBarcode
    * userEntityRequest.patronGroup = karate.get('extGroupId', intUserGroupId)
    * userEntityRequest.id = karate.get('extUserId', intUserId)
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

  Scenario: Create Transaction
    * def createDCBTransactionRequest = read('samples/transaction/create-dcb-transaction.json')

    Given path '/transactions/' + dcbTransactionId
    And request createDCBTransactionRequest
    When method POST
    Then status 201

  Scenario: Get check-in records, define current item check-in record and its status
    # checkIn the item
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')

    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkInRequest.checkInDate = karate.get('extCheckInDate', intCheckInDate)
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'In transit'
    And call pause 5000


    # get check-ins and assert checkedIn record
    Given path 'check-in-storage', 'check-ins'
    When method GET
    Then status 200
    * def checkedInRecord = response.checkIns[response.totalRecords - 1]
    And match checkedInRecord.itemId == extItemId

    Given path 'check-in-storage', 'check-ins', checkedInRecord.id
    When method GET
    Then status 200
    And match response.itemStatusPriorToCheckIn == 'Open'
    And match response.itemId == extItemId

  Scenario: Update DCB transaction status to OPEN.
    * def updateDCBTransactionStatusRequest = read('samples/transaction/update-dcb-transaction-status.json')
    Given path '/transactions/' + dcbTransactionId
    And request
        """
        {
          "status": "OPEN"
        }
        """
    When method PUT
    Then status 200

  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched
    # checkOut the item for the user
    * def checkOutByBarcodeEntityRequest = read('samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = extItemBarcode
    * checkOutByBarcodeEntityRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkOutByBarcodeEntityRequest.loanDate = karate.get('extLoanDate', intLoanDate)
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201

    # get the loan and verify that correct loan-policy has been applied
    Given path 'circulation', 'loans'
    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + extItemId + ')'
    When method GET
    Then status 200
    And match response.loans[0].id == checkOutResponse.response.id
    And match response.loans[0].loanPolicyId == loanPolicyMaterialId

  Scenario: Update DCB transaction status to ITEM_CHECKED_OUT
    * def updateDCBTransactionStatusRequest = read('samples/DCBTransaction/update-dcb-transaction-status.json')
    Given path '/transactions/' + dcbTransactionId
    And request
        """
        {
          "status": "ITEM_CHECKED_OUT"
        }
        """
    When method PUT
    Then status 200

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
