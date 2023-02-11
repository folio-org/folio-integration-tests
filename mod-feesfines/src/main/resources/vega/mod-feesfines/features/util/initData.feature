Feature: init data

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def servicePointId = '9f64b1fd-fc6c-452d-81c5-4144dd2d8328'
    * def locationId = 'fffd1d87-5eae-4314-875a-edeba5020f16'
    * def instanceId = '091141f4-995e-43a0-9ffc-aecdc0e2c3cb'
    * def holdingsId = '4bdd6975-5f1e-471b-91a4-54d49684dd39'
    * def itemId = '905d9b01-609b-4ca1-b242-10fe7771f8cd'
    * def materialTypeId = 'd6fc7a05-e7bb-492e-affd-f3b46c102417'
    * def patronGroupId = '0a035fa4-e98d-46fd-9dbd-f867c33e2bda'
    * def userId = '62909c21-2bac-46b6-96d4-af90f64bf024'
    * def contributorNameTypeId = '4c8e5d88-f8ba-4b74-b8e7-389bb93c8a25'
    * def loanTypeId = '47d393ac-f94e-4e5c-825c-3632d1a1aab6'
    * def itemBarcode = 'item.barcode'
    * def userBarcode = 'user.barcode'

  @PostLocation
  Scenario: create location
    * def intInstitutionId = call uuid1
    * def intCampusId = call uuid1
    * def intLibraryId = call uuid1

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

  @PostOwner
  Scenario: create owner
    * def intOwnerId = call uuid1
    * def ownerEntityRequest = read('samples/owner-entity-request.json')
    * ownerEntityRequest.id = karate.get('extOwnerId', intOwnerId)

    Given path 'owners'
    And request ownerEntityRequest
    When method POST
    Then status 201

  @PostInstance
  Scenario: create instance
    * def intInstanceTypeId = call uuid1
    * def instanceTypeEntityRequest = read('samples/instance-type-entity-request.json')
    * instanceTypeEntityRequest.id = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()

    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.id = karate.get('extContributorNameTypeId', contributorNameTypeId)
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('samples/instance-entity-request.json')
    * instanceEntityRequest.instanceTypeId = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceEntityRequest.id = karate.get('extInstanceId', instanceId)
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: create holdings
    * def holdingsEntityRequest = read('samples/holdings-entity-request.json')
    * holdingsEntityRequest.id = karate.get('extHoldingsRecordId', holdingsId)
    * holdingsEntityRequest.instanceId = karate.get('extInstanceId', instanceId)
    * holdingsEntityRequest.permanentLocationId = karate.get('extLocationId', locationId)
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def intMaterialTypeName = 'book'
    * def materialTypeEntityRequest = read('samples/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', materialTypeId)
    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', intMaterialTypeName)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @PostItem
  Scenario: create item
    * def permanentLoanTypeEntityRequest = read('samples/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.id = karate.get('extPermanentLoanTypeId', loanTypeId)
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item-entity-request.json')
    * itemEntityRequest.barcode = karate.get('extItemBarcode', itemBarcode)
    * itemEntityRequest.id = karate.get('extItemId', itemId)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingsId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', materialTypeId)
    * itemEntityRequest.permanentLoanType.id = karate.get('extPermanentLoanTypeId', loanTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', 'Available')
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostPatronGroup
  Scenario: create parton group
    * def groupEntityRequest = read('samples/group-entity-request.json')
    * groupEntityRequest.id = karate.get('extPatronGroupId', patronGroupId)
    * groupEntityRequest.group = groupEntityRequest.group + ' ' + random_string()
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

  @PostUser
  Scenario: create user
    * def userEntityRequest = read('samples/user-request-entity.json')
    * userEntityRequest.barcode = karate.get('extUserBarcode', userBarcode)
    * userEntityRequest.patronGroup = karate.get('extPatronGroupId', patronGroupId)
    * userEntityRequest.id = karate.get('extUserId', userId)
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

  @PostCheckOut
  Scenario: do check out
    * def intLoanDate = '2021-10-27T13:25:46.000Z'
    * def intCheckOutId = call uuid1
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.id = karate.get('extCheckOutId', intCheckOutId)
    * checkOutByBarcodeEntityRequest.userBarcode = karate.get('extUserBarcode', userBarcode)
    * checkOutByBarcodeEntityRequest.itemBarcode = karate.get('extItemBarcode', itemBarcode)
    * checkOutByBarcodeEntityRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkOutByBarcodeEntityRequest.loanDate = karate.get('extLoanDate', intLoanDate)
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201

  @PostDeclareLost
  Scenario: declare item lost
    * def declareLostRequest = read('classpath:vega/mod-feesfines/features/samples/declare-item-lost-request-entity.json')
    * def currentDateTime = call read('classpath:vega/mod-feesfines/features/util/date-now-function.js')
    * declareLostRequest.declaredLostDateTime = karate.get('extDeclaredLostDateTime', currentDateTime)
    Given path 'circulation', 'loans', extLoanId, 'declare-item-lost'
    And request declareLostRequest
    When method POST
    Then status 204

  @PostCancelActualCostFeeFine
  Scenario: cancel actual cost fee/fine
    * def additionalInfoForStaff = karate.get('extAdditionalInfoForStaff', 'Comment for staff')
    * def additionalInfoForPatron = karate.get('extAdditionalInfoForPatron', 'Comment for patron')
    * def actualCostFeeFineCancelRequest = read('classpath:vega/mod-feesfines/features/samples/actual-cost-fee-fine-cancel-request-entity.json')
    * actualCostFeeFineCancelRequest.actualCostRecordId = extActualCostRecordId
    * actualCostFeeFineCancelRequest.additionalInfoForStaff = additionalInfoForStaff
    * actualCostFeeFineCancelRequest.additionalInfoForPatron = additionalInfoForPatron

    Given path 'actual-cost-fee-fine', 'cancel'
    And request actualCostFeeFineCancelRequest
    When method POST
    Then status 201
    Then match response.id == extActualCostRecordId
    Then match response.status == 'Cancelled'
    Then match response.additionalInfoForStaff == additionalInfoForStaff
    Then match response.additionalInfoForPatron == additionalInfoForPatron