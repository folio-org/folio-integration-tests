Feature: Testing Lending Flow

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain'  }
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
    * def servicePointEntityRequest = read('classpath:volaris/mod-dcb/features/samples/service-point/service-point-entity-request.json')
#    * servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

    * def servicePointEntityRequest1 = read('classpath:volaris/mod-dcb/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest1.id = servicePointId11
    * servicePointEntityRequest1.name = servicePointName11
    * servicePointEntityRequest1.code = servicePointCode11

    Given path 'service-points'
    And request servicePointEntityRequest1
    When method POST
    Then status 201

    * def servicePointEntityRequest2 = read('classpath:volaris/mod-dcb/features/samples/service-point/service-point-entity-request.json')
    * servicePointEntityRequest2.id = servicePointId21
    * servicePointEntityRequest2.name = servicePointName21
    * servicePointEntityRequest2.code = servicePointCode21

    Given path 'service-points'
    And request servicePointEntityRequest2
    When method POST
    Then status 201


  @PostLocation
  Scenario: Create Location
    * def locationUnitInstitutionEntityRequest = read('classpath:volaris/mod-dcb/features/samples/location/location-unit-institution-entity-request.json')
    * locationUnitInstitutionEntityRequest.id = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitInstitutionEntityRequest.name = locationUnitInstitutionEntityRequest.name + ' ' + random_string()
    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('classpath:volaris/mod-dcb/features/samples/location/location-unit-campus-entity-request.json')
    * locationUnitCampusEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationUnitCampusEntityRequest.id = karate.get('extCampusId', intCampusId)
    * locationUnitCampusEntityRequest.name = locationUnitCampusEntityRequest.name + ' ' + random_string()
    * locationUnitCampusEntityRequest.code = locationUnitCampusEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('classpath:volaris/mod-dcb/features/samples/location/location-unit-library-entity-request.json')
    * locationUnitLibraryEntityRequest.id = karate.get('extLibraryId', intLibraryId)
    * locationUnitLibraryEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationUnitLibraryEntityRequest.name = locationUnitLibraryEntityRequest.name + ' ' + random_string()
    * locationUnitLibraryEntityRequest.code = locationUnitLibraryEntityRequest.code + ' ' + random_string()
    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('classpath:volaris/mod-dcb/features/samples/location/location-entity-request.json')
    * locationEntityRequest.id = karate.get('extLocationId', locationId)
    * locationEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationEntityRequest.libraryId = karate.get('extLibraryId', intLibraryId)
   # * locationEntityRequest.primaryServicePoint = karate.get('extServicePointId', servicePointId)
   # * locationEntityRequest.servicePointIds = [karate.get('extServicePointId', servicePointId)]
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

    Given path 'holdings-sources/'
    And headers headersUser
    And param query = 'name==FOLIO'
    When method GET
    Then status 200

    * holdingsEntityRequest.sourceId = response.holdingsRecordsSources[0].id

    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def materialTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', materialTypeName)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @PostItem
  Scenario: Create Items
    * def permanentLoanTypeEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = itemBarcode
    * itemEntityRequest.id = karate.get('extItemId', intItemId)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest1 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest1.barcode = itemBarcode1
    * itemEntityRequest1.id = karate.get('extItemId1', intItemId1)
    * itemEntityRequest1.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest1.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest1.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest1
    When method POST
    Then status 201

    * def itemEntityRequest2 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest2.barcode = itemBarcode2
    * itemEntityRequest2.id = karate.get('extItemId2', intItemId2)
    * itemEntityRequest2.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest2.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest2.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest2
    When method POST
    Then status 201

    * def itemEntityRequest3 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest3.barcode = itemBarcode3
    * itemEntityRequest3.id = karate.get('extItemId3', intItemId3)
    * itemEntityRequest3.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest3.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest3.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest3
    When method POST
    Then status 201

    * def itemEntityRequest4 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest4.barcode = itemBarcode4
    * itemEntityRequest4.id = karate.get('extItemId4', intItemId4)
    * itemEntityRequest4.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest4.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest4.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest4
    When method POST
    Then status 201

    * def itemEntityRequest5 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest5.barcode = itemBarcode5
    * itemEntityRequest5.id = karate.get('extItemId5', intItemId4)
    * itemEntityRequest5.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest5.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest5.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest5
    When method POST
    Then status 201

    * def itemEntityRequest6 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest6.barcode = itemBarcode6
    * itemEntityRequest6.id = karate.get('extItemId6', intItemId6)
    * itemEntityRequest6.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest6.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest6.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest6
    When method POST
    Then status 201

    * def itemEntityRequest7 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest7.barcode = itemBarcode11
    * itemEntityRequest7.id = itemId11
    * itemEntityRequest7.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest7.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest7.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest7
    When method POST
    Then status 201

    * def itemEntityRequest8 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest8.barcode = itemBarcode51
    * itemEntityRequest8.id = itemId51
    * itemEntityRequest8.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest8.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest8.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest8
    When method POST
    Then status 201

    * def itemEntityRequest9 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest9.barcode = itemBarcode61
    * itemEntityRequest9.id = itemId61
    * itemEntityRequest9.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest9.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest9.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest9
    When method POST
    Then status 201

    * def itemEntityRequest10 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest10.barcode = itemBarcode71
    * itemEntityRequest10.id = itemId71
    * itemEntityRequest10.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest10.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest10.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest10
    When method POST
    Then status 201

    * def itemEntityRequest11 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest11.barcode = itemBarcode110
    * itemEntityRequest11.id = itemId110
    * itemEntityRequest11.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest11.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest11.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest11
    When method POST
    Then status 201

    * def itemEntityRequest12 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemEntityRequest12.barcode = itemBarcode112
    * itemEntityRequest12.id = itemId112
    * itemEntityRequest12.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest12.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest12.status.name = karate.get('extStatusName', intStatusName)

    Given path 'inventory', 'items'
    And request itemEntityRequest12
    When method POST
    Then status 201

  @PostGroup
  Scenario: Create Groups
    * def groupEntityRequest = read('classpath:volaris/mod-dcb/features/samples/user/group-entity-request.json')
    * groupEntityRequest.id = karate.get('extUserGroupId', intUserGroupId)
    * groupEntityRequest.group = groupEntityRequest.group + ' ' + random_string()
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

    * def groupEntityRequest1 = read('classpath:volaris/mod-dcb/features/samples/user/group-entity-request.json')
    * groupEntityRequest1.id = patronGroupId
    * groupEntityRequest1.group = patronGroupName
    Given path 'groups'
    And request groupEntityRequest1
    When method POST
    Then status 201

  Scenario: create Patron
    * def createPatronGroupRequest = read('classpath:volaris/mod-dcb/features/samples/patron/create-patronGroup-request.json')
    Given path 'groups'
    And request createPatronGroupRequest
    When method POST
    Then status 201

  @PostUser
  Scenario: Create Users
    * def intUserId = '8b83f6b6-77b3-11ee-b962-0242ac120002'
    * def userEntityRequest = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest.barcode = extUserBarcode
    * userEntityRequest.patronGroup = karate.get('extGroupId', intUserGroupId)
    * userEntityRequest.id = karate.get('extUserId', intUserId)
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

    * def intUserId1 = '8b83f6b6-77b3-11ee-b962-0242ac120003'
    * def userEntityRequest1 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest1.barcode = extUserBarcode1
    * userEntityRequest1.patronGroup = karate.get('extGroupId', intUserGroupId)
    * userEntityRequest1.id = karate.get('extUserId1', intUserId1)
    Given path 'users'
    And request userEntityRequest1
    When method POST
    Then status 201

    * def userEntityRequest2 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest2.id = patronId21
    * userEntityRequest2.barcode = patronBarcode21
    Given path 'users'
    And request userEntityRequest2
    When method POST
    Then status 201

    * def userEntityRequest3 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest3.id = patronId31
    * userEntityRequest3.barcode = patronBarcode31
    Given path 'users'
    And request userEntityRequest3
    When method POST
    Then status 201

    * def userEntityRequest5 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest5.id = patronId51
    * userEntityRequest5.barcode = patronBarcode51
    * userEntityRequest5.type = 'dcb'
    Given path 'users'
    And request userEntityRequest5
    When method POST
    Then status 201

    * def userEntityRequest6 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest6.id = patronId1
    * userEntityRequest6.barcode = patronBarcode1

    Given path 'users'
    And request userEntityRequest6
    When method POST
    Then status 201

    * def userEntityRequest7 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest7.id = patronId110
    * userEntityRequest7.barcode = patronBarcode110
    * userEntityRequest7.type = 'patron'

    Given path 'users'
    And request userEntityRequest7
    When method POST
    Then status 201

    * def userEntityRequest8 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest8.id = patronId2
    * userEntityRequest8.barcode = patronBarcode2

    Given path 'users'
    And request userEntityRequest8
    When method POST
    Then status 201

    * def userEntityRequest9 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * userEntityRequest9.id = patronId111
    * userEntityRequest9.barcode = patronBarcode111
    * userEntityRequest9.type = 'patron'

    Given path 'users'
    And request userEntityRequest9
    When method POST
    Then status 201


  @CreateLoanPolicy
  Scenario: Create loan policy
    Given path 'loan-policy-storage/loan-policies'
    And request
    """
    {
    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
    "name": "loanPolicyName",
    "loanable": true,
    "loansPolicy": {
        "profileId": "Rolling",
        "period": {
            "duration": 1,
            "intervalId": "Hours"
        },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
    },
    "renewable": true,
    "renewalsPolicy": {
        "unlimited": false,
        "numberAllowed": 3.0,
        "renewFromId": "SYSTEM_DATE",
        "differentPeriod": false
    }
    }
    """
    When method POST

  @CreateRequestPolicy
  Scenario: Create request policy
    Given path 'request-policy-storage/request-policies'
    And request
    """
    {
    "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
    "name": "requestPolicyName",
    "description": "Allow all request types",
    "requestTypes": [
        "Hold",
        "Page",
        "Recall"
    ]
    }
    """
    When method POST
  @CreateNoticePolicy
  Scenario: Create notice policy
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
    """
    {
    "id": "122b3d2b-4788-4f1e-9117-56daa91cb75c",
    "name": "patronNoticePolicyName",
    "description": "A basic notice policy that does not define any notices",
    "active": true,
    "loanNotices": [],
    "feeFineNotices": [],
    "requestNotices": []
    }
    """
    When method POST

  @CreateOverdueFinePolicy
  Scenario: Create overdue fine policy
    Given path 'overdue-fines-policies'
    And request
    """
    {
    "name": "overdueFinePolicyName",
    "description": "Test overdue fine policy",
    "countClosed": true,
    "maxOverdueFine": 0.0,
    "forgiveOverdueFine": true,
    "gracePeriodRecall": true,
    "maxOverdueRecallFine": 0.0,
    "id": "cd3f6cac-fa17-4079-9fae-2fb28e521412"
    }
    """
    When method POST

  @CreateLostItemFeesPolicy
  Scenario: Create lost item fees policy
    Given path 'lost-item-fees-policies'
    And request
    """
    {
    "name": "lostItemFeesPolicyName",
    "description": "Test lost item fee policy",
    "chargeAmountItem": {
        "chargeType": "actualCost",
        "amount": 0.0
    },
    "lostItemProcessingFee": 0.0,
    "chargeAmountItemPatron": true,
    "chargeAmountItemSystem": true,
    "lostItemChargeFeeFine": {
        "duration": 2,
        "intervalId": "Days"
    },
    "returnedLostItemProcessingFee": true,
    "replacedLostItemProcessingFee": true,
    "replacementProcessingFee": 0.0,
    "replacementAllowed": true,
    "lostItemReturned": "Charge",
    "id": "ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
    }
    """
    When method POST

  @CirculationRules
  Scenario: Update circulation rules
    Given path 'circulation/rules'
    And request
    """
    {
    "id": "1721f01b-e69d-5c4c-5df2-523428a04c55",
    "rulesAsText": "priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709 \nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
    }
    """
    When method PUT

  @PostCancellationReason
  Scenario: create a cancellation reason
    * def cancellationReasonRequest = read('classpath:volaris/mod-dcb/features/samples/request/cancellation-reason-entity-request.json')
    * cancellationReasonRequest.id = karate.get('extCancellationReasonId', cancellationReasonId)
    Given path 'cancellation-reason-storage', 'cancellation-reasons'
    And request cancellationReasonRequest
    When method POST
    Then status 201