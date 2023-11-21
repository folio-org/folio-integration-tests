Feature: Testing Lending Flow

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
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
    #* servicePointEntityRequest.id = karate.get('extServicePointId', servicePointId)
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
    * itemEntityRequest.barcode = itemBarcode
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

  Scenario: create Patron
    * def createPatronGroupRequest = read('classpath:volaris/mod-dcb/features/samples/patron/create-patronGroup-request.json')
    Given path 'groups'
    And request createPatronGroupRequest
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

#  @UpdateRules
#  Scenario: create policies
#
#    * def materialTypeId = 'e46d3a86-7eb5-11ee-b962-0242ac120002'
#    * def materialTypeName = 'e-book'
#    * def requestPolicyIdForGroup = '11601e40-55c9-45c7-90e1-559db790bdf5'
#    * def requestPolicyIdForGroup2 = 'cd54fde8-7eb5-11ee-b962-0242ac120002'
#    * def requestPolicyIdForGroup3 = 'd3ed7ea0-7eb5-11ee-b962-0242ac120002'
#    * def requestPolicyIdForGroup4 = 'db873b7e-7eb5-11ee-b962-0242ac120002'
#    * def extRequestTypesForFirstUserGroupRequestPolicy = ["Hold", "Recall"]
#    * def extRequestTypesForSecondUserGroupRequestPolicy = ["Page", "Recall"]
#    * def extRequestTypesForThirdUserGroupRequestPolicy = ["Page", "Hold"]
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }
#
#        # policies
#    * def loanPolicyId = call uuid1
#    * def loanPolicyMaterialId = call uuid1
#    * def lostItemFeePolicyId = call uuid1
#    * def overdueFinePoliciesId = call uuid1
#    * def patronPolicyId = call uuid1
#    * def requestPolicyId = call uuid1
#
#    * def extFallbackPolicy = { loanPolicyId: #(loanPolicyId), lostItemFeePolicyId: #(lostItemFeePolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), patronPolicyId: #(patronPolicyId), requestPolicyId: #(requestPolicyId) }
#    * def extMaterialTypePolicy = { materialTypeId: #(materialTypeId), loanPolicyId: #(loanPolicyMaterialId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyId), patronPolicyId: #(patronPolicyId) }
#    * def extFirstGroupPolicy = { userGroupId: #(firstUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup), patronPolicyId: #(patronPolicyId) }
#    * def extSecondGroupPolicy = { userGroupId: #(secondUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup2), patronPolicyId: #(patronPolicyId) }
#    * def extThirdGroupPolicy = { userGroupId: #(thirdUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup3), patronPolicyId: #(patronPolicyId) }
#    * def extFourthGroupPolicy = { userGroupId: #(fourthUserGroupId), loanPolicyId: #(loanPolicyId), overdueFinePoliciesId: #(overdueFinePoliciesId), lostItemFeePolicyId: #(lostItemFeePolicyId), requestPolicyId: #(requestPolicyIdForGroup4), patronPolicyId: #(patronPolicyId) }
#
#
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyMaterialId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup), extRequestTypes: #(extRequestTypesForFirstUserGroupRequestPolicy) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup2), extRequestTypes: #(extRequestTypesForSecondUserGroupRequestPolicy) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup3), extRequestTypes: #(extRequestTypesForThirdUserGroupRequestPolicy) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyIdForGroup4) }
#    * callonce read('classpath:volaris/mod-dcb/features/util/initData.feature@PostRulesWithMaterialTypeAndGroup') extFallbackPolicy, extMaterialTypePolicy, extFirstGroupPolicy, extSecondGroupPolicy, extThirdGroupPolicy, extFourthGroupPolicy
#
#
#    # get current circulation rules as text
#    Given path 'circulation', 'rules'
#    When method GET
#    Then status 200
#    * def currentCirculationRulesAsText = response.rulesAsText
#
#    * def fallbackPolicy = 'fallback-policy: l ' + extFallbackPolicy.loanPolicyId + ' o ' + extMaterialTypePolicy.overdueFinePoliciesId + ' i ' + extMaterialTypePolicy.lostItemFeePolicyId + ' r ' + extMaterialTypePolicy.requestPolicyId + ' n ' + extMaterialTypePolicy.patronPolicyId
#    * def materialTypePolicy = 'm ' + extMaterialTypePolicy.materialTypeId + ': l ' + extMaterialTypePolicy.loanPolicyId + ' o ' + extMaterialTypePolicy.overdueFinePoliciesId + ' i ' + extMaterialTypePolicy.lostItemFeePolicyId + ' r ' + extMaterialTypePolicy.requestPolicyId + ' n ' + extMaterialTypePolicy.patronPolicyId
#    # enter new circulation rule in the circulation editor
#    * def rules = 'priority: number-of-criteria, criterium (t, s, c, b, a, m, g), last-line\n'+fallbackPolicy+' \n'+materialTypePolicy
#    * def updateRulesEntity = { "rulesAsText": "#(rules)" }
#    Given path 'circulation', 'rules'
#    And request updateRulesEntity
#    When method PUT
#    Then status 204


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

  Scenario: Create Transaction
    Given path '/transactions/' + dcbTransactionId
    And request
    """
    {
        "item": {
          "id": "c7a2f4de-77af-11ee-b962-0242ac120002",
          "title": "Test",
          "barcode": "#(itemBarcode)",
          "pickupLocation": "Datalogisk Institut",
          "materialType": "book",
          "lendingLibraryCode": "KU"
        },
        "patron": {
          "id": "ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2",
          "group": "patronName",
          "barcode": "11111",
          "borrowingLibraryCode": "E"
        },
        "pickup": {
        "servicePointId": "afbd1042-794a-11ee-b962-0242ac120003",
        "servicePointName": "TestServicePointCode6",
        "libraryName": "TestLibraryName6",
        "libraryCode": "TestLibraryCode6"
        },
        "role": "LENDER"
    }
    """
    When method POST
    Then status 201

  Scenario: Check Transaction status. CREATED
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200

  Scenario: Get check-in records, define current item check-in record and its status
    # checkIn the item
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')

    Given path 'circulation', 'check-in-by-barcode'
    And request
      """
      {
        "servicePointId": "afbd1042-794a-11ee-b962-0242ac120002",
        "checkInDate": "#(intCheckInDate)",
        "itemBarcode": "#(itemBarcode)",
        "id": "#(checkInId)"
      }
      """
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.item.status.name == 'In transit'
    And call pause 5000

  Scenario: Check Transaction status. OPEN
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200

  Scenario: Update DCB transaction status to AWAITING_PICKUP.
    Given path '/transactions/' + dcbTransactionId + '/status'
    And request
        """
        {
          "status": "AWAITING_PICKUP"
        }
        """
    When method PUT
    Then status 200

#  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched
#    # checkOut the item for the user
#    * def checkOutByBarcodeEntityRequest = read('samples/check-out/check-out-by-barcode-entity-request.json')
#    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
#    * checkOutByBarcodeEntityRequest.itemBarcode = extItemBarcode
#    * checkOutByBarcodeEntityRequest.servicePointId = karate.get('extServicePointId', servicePointId)
#    * checkOutByBarcodeEntityRequest.loanDate = karate.get('extLoanDate', intLoanDate)
#    Given path 'circulation', 'check-out-by-barcode'
#    And request checkOutByBarcodeEntityRequest
#    When method POST
#    Then status 201
#
#    # get the loan and verify that correct loan-policy has been applied
#    Given path 'circulation', 'loans'
#    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + extItemId + ')'
#    When method GET
#    Then status 200
#    And match response.loans[0].id == checkOutResponse.response.id
#    And match response.loans[0].loanPolicyId == loanPolicyMaterialId


  @PutServicePointNonPickupLocation
  Scenario: Update service point
    * def id = 'f74a04a2-779b-11ee-b962-0242ac120002'
    * def servicePoint = read('samples/service-point/service-point-entity-request.json')
    #* servicePoint.id = karate.get('extServicePointId', servicePointId)
    * servicePoint.name = servicePoint.name
    * servicePoint.code = servicePoint.code
    * servicePoint.pickupLocation = false
    * remove servicePoint.holdShelfExpiryPeriod
    Given path 'service-points', servicePoint.id
    And request servicePoint
    When method PUT
    Then status 204
