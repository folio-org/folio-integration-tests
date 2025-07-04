Feature: init data for mod-circulation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }

  @PostInstance
  Scenario: create instance
    * def intInstanceTypeId = call uuid1
    * def contributorNameTypeId = call uuid1
    * def instanceTypeEntityRequest = read('samples/instance/instance-type-entity-request.json')
    * instanceTypeEntityRequest.id = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceTypeEntityRequest.name = instanceTypeEntityRequest.name + ' ' + random_string()
    * instanceTypeEntityRequest.code = instanceTypeEntityRequest.code + ' ' + random_string()
    * instanceTypeEntityRequest.source = instanceTypeEntityRequest.source + ' ' + random_string()

    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/instance/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = contributorNameTypeEntityRequest.name + ' ' + random_string()
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('samples/instance/instance-entity-request.json')
    * instanceEntityRequest.instanceTypeId = karate.get('extInstanceTypeId', intInstanceTypeId)
    * instanceEntityRequest.id = karate.get('extInstanceId', instanceId)
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
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

  @PostOwner
  Scenario: create owner
    * def ownerEntityRequest = read('samples/feefine/owner-entity-request.json')

    Given path 'owners'
    And request ownerEntityRequest
    When method POST
    Then status 201

  @PostManualCharge
  Scenario: create manual charge
    * def manualChargeEntityRequest = read('samples/feefine/manual-charge-entity-request.json')
    * manualChargeEntityRequest.id = karate.get('extManualChargeId', manualChargeId)
    Given path 'feefines'
    And request manualChargeEntityRequest
    When method POST
    Then status 201

  @PostPaymentMethod
  Scenario: create payment method
    * def paymentMethodEntityRequest = read('samples/feefine/payment-method-entity-request.json')
    Given path 'payments'
    And request paymentMethodEntityRequest
    When method POST
    Then status 201

  @PostPay
  Scenario: make payment
    * def payEntityRequest = read('samples/feefine/pay-entity-request.json')

    Given path 'accounts/' + accountId + '/pay'
    And request payEntityRequest
    When method POST
    Then status 201

  @PostLocation
  Scenario: create location
    * def intInstitutionId = call uuid1
    * def intCampusId = call uuid1
    * def intLibraryId = call uuid1
    * def randomLocationId = call uuid1
    * def intLocationId = locationId ? locationId : randomLocationId
    * def randomServicePointId = call uuid1
    * def intServicePointId = servicePointId ? servicePointId : randomServicePointId

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
    * locationEntityRequest.id = karate.get('extLocationId', intLocationId)
    * locationEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationEntityRequest.libraryId = karate.get('extLibraryId', intLibraryId)
    * locationEntityRequest.primaryServicePoint = karate.get('extServicePointId', intServicePointId)
    * locationEntityRequest.servicePointIds = [karate.get('extServicePointId', intServicePointId)]
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()
    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: create holdings
    * def sourceIdEntityRequest = read('samples/source-record-entity-request.json')
    * sourceIdEntityRequest.id = karate.get('extHoldingSourceId', holdingSourceId)
    * sourceIdEntityRequest.name = karate.get('extHoldingSourceName', 'TestUser-' + holdingSourceName)
    Given path 'holdings-sources'
    And request sourceIdEntityRequest
    When method POST
    Then status 201

    * def holdingsEntityRequest = read('samples/holdings-entity-request.json')
    * holdingsEntityRequest.id = karate.get('extHoldingsRecordId', holdingId)
    * holdingsEntityRequest.instanceId = karate.get('extInstanceId', instanceId)
    * holdingsEntityRequest.sourceId = karate.get('sourceId', holdingSourceId)
    * holdingsEntityRequest.permanentLocationId = karate.get('extLocationId', locationId)
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostMaterialType
  Scenario: create material type
    * def intMaterialTypeId = call uuid1
    * def materialTypeName = call random_string
    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * materialTypeEntityRequest.name = karate.get('extMaterialTypeName', materialTypeName)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

  @PostItem
  Scenario: create item
    * def permanentLoanTypeId = call uuid1
    * def intMaterialTypeId = call uuid1
    * def intItemId = call uuid1
    * def intStatusName = 'Available'

    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = extItemBarcode
    * itemEntityRequest.id = karate.get('extItemId', intItemId)
    * itemEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId', holdingId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * itemEntityRequest.status.name = karate.get('extStatusName', intStatusName)
    * itemEntityRequest.permanentLoanType.id = permanentLoanTypeId
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostLoanPolicy
  Scenario: create loan policy
    * def intLoanPolicyId = call uuid1

    * def loanPolicyEntityRequest = read('samples/policies/loan-policy-entity-request.json')
    * loanPolicyEntityRequest.id = karate.get('extLoanPolicyId', intLoanPolicyId)
    * loanPolicyEntityRequest.name = loanPolicyEntityRequest.name + ' ' + random_string()
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

  @PostLoanPolicyWithLimit
  Scenario: create loan policy with limit
    * def intLoanPolicyId = call uuid1

    * def loanPolicyEntityRequest = read('samples/policies/loan-policy-entity-with-limit-request.json')
    * loanPolicyEntityRequest.id = karate.get('extLoanPolicyId', intLoanPolicyId)
    * loanPolicyEntityRequest.name = loanPolicyEntityRequest.name + ' ' + random_string()
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

  @PostLostPolicy
  Scenario: create lost policy
    * def intLostItemPolicyId = call uuid1

    * def lostItemFeePolicyEntityRequest = read('samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.id = karate.get('extLostItemFeePolicyId', intLostItemPolicyId)
    * lostItemFeePolicyEntityRequest.name = lostItemFeePolicyEntityRequest.name + ' ' + random_string()
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

  @PostOverduePolicy
  Scenario: create overdue policy
    * def intOverduePolicyId = call uuid1

    * def overdueFinePolicyEntityRequest = read('samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.id = karate.get('extOverdueFinePoliciesId', intOverduePolicyId)
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' ' + random_string()
    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

  @PostPatronPolicy
  Scenario: create patron policy
    * def intPatronPolicyId = call uuid1

    * def patronNoticePolicyEntityRequest = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.id = karate.get('extPatronPolicyId', intPatronPolicyId)
    * patronNoticePolicyEntityRequest.name = patronNoticePolicyEntityRequest.name + ' ' + random_string()
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

  @PostRequestPolicy
  Scenario: create request policy
    * def intRequestPolicyId = call uuid1
    * def intRequestTypes = ["Hold", "Page", "Recall"]

    * def requestPolicyEntityRequest = read('samples/policies/request-policy-entity-request.json')
    * requestPolicyEntityRequest.id = karate.get('extRequestPolicyId', intRequestPolicyId)
    * requestPolicyEntityRequest.name = requestPolicyEntityRequest.name + ' ' + random_string()
    * requestPolicyEntityRequest.requestTypes = karate.get('extRequestTypes', intRequestTypes)
    * requestPolicyEntityRequest.allowedServicePoints = karate.get('extAllowedServicePoints', {})
    Given path 'request-policy-storage/request-policies'
    And request requestPolicyEntityRequest
    When method POST
    Then status 201

  @PostRulesWithMaterialTypeAndGroup
  Scenario: create policies with material and group
    * def fallbackPolicy = 'fallback-policy: l ' + extFallbackPolicy.loanPolicyId + ' o ' + extFallbackPolicy.overdueFinePoliciesId + ' i ' + extFallbackPolicy.lostItemFeePolicyId + ' r ' + extFallbackPolicy.requestPolicyId + ' n ' + extFallbackPolicy.patronPolicyId
    * def materialTypePolicy = 'm ' + extMaterialTypePolicy.materialTypeId + ': l ' + extMaterialTypePolicy.loanPolicyId + ' o ' + extMaterialTypePolicy.overdueFinePoliciesId + ' i ' + extMaterialTypePolicy.lostItemFeePolicyId + ' r ' + extMaterialTypePolicy.requestPolicyId + ' n ' + extMaterialTypePolicy.patronPolicyId
    * def groupPolicy = 'g ' + extFirstGroupPolicy.userGroupId + ': l ' + extFirstGroupPolicy.loanPolicyId + ' o ' + extFirstGroupPolicy.overdueFinePoliciesId + ' i ' + extFirstGroupPolicy.lostItemFeePolicyId + ' r ' + extFirstGroupPolicy.requestPolicyId + ' n ' + extFirstGroupPolicy.patronPolicyId
    * def groupPolicy2 = 'g ' + extSecondGroupPolicy.userGroupId + ': l ' + extSecondGroupPolicy.loanPolicyId + ' o ' + extSecondGroupPolicy.overdueFinePoliciesId + ' i ' + extSecondGroupPolicy.lostItemFeePolicyId + ' r ' + extSecondGroupPolicy.requestPolicyId + ' n ' + extSecondGroupPolicy.patronPolicyId
    * def groupPolicy3 = 'g ' + extThirdGroupPolicy.userGroupId + ': l ' + extThirdGroupPolicy.loanPolicyId + ' o ' + extThirdGroupPolicy.overdueFinePoliciesId + ' i ' + extThirdGroupPolicy.lostItemFeePolicyId + ' r ' + extThirdGroupPolicy.requestPolicyId + ' n ' + extThirdGroupPolicy.patronPolicyId
    * def groupPolicy4 = 'g ' + extFourthGroupPolicy.userGroupId + ': l ' + extFourthGroupPolicy.loanPolicyId + ' o ' + extFourthGroupPolicy.overdueFinePoliciesId + ' i ' + extFourthGroupPolicy.lostItemFeePolicyId + ' r ' + extFourthGroupPolicy.requestPolicyId + ' n ' + extFourthGroupPolicy.patronPolicyId
    * def rules = 'priority: t, s, c, b, a, m, g ' + fallbackPolicy + '\n' + materialTypePolicy + '\n' + groupPolicy + '\n' + groupPolicy2 + '\n' + groupPolicy3 + '\n' + groupPolicy4
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204


  @UpdateRules
  Scenario: create policies
    # get current circulation rules as text
    Given path 'circulation', 'rules'
    When method GET
    Then status 200
    * def currentCirculationRulesAsText = response.rulesAsText

    * def fallbackPolicy = 'fallback-policy: l ' + extFallbackPolicy.loanPolicyId + ' o ' + extMaterialTypePolicy.overdueFinePoliciesId + ' i ' + extMaterialTypePolicy.lostItemFeePolicyId + ' r ' + extMaterialTypePolicy.requestPolicyId + ' n ' + extMaterialTypePolicy.patronPolicyId
    * def materialTypePolicy = 'm ' + extMaterialTypePolicy.materialTypeId + ': l ' + extMaterialTypePolicy.loanPolicyId + ' o ' + extMaterialTypePolicy.overdueFinePoliciesId + ' i ' + extMaterialTypePolicy.lostItemFeePolicyId + ' r ' + extMaterialTypePolicy.requestPolicyId + ' n ' + extMaterialTypePolicy.patronPolicyId
    # enter new circulation rule in the circulation editor
    * def rules = 'priority: number-of-criteria, criterium (t, s, c, b, a, m, g), last-line\n'+fallbackPolicy+' \n'+materialTypePolicy
    * def updateRulesEntity = { "rulesAsText": "#(rules)" }
    Given path 'circulation', 'rules'
    And request updateRulesEntity
    When method PUT
    Then status 204

  @PostGroup
  Scenario: create group
    * def intUserGroupId = call uuid1
    * def groupEntityRequest = read('samples/user/group-entity-request.json')
    * groupEntityRequest.id = karate.get('extUserGroupId', intUserGroupId)
    * groupEntityRequest.group = groupEntityRequest.group + ' ' + random_string()
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

  @PostUser
  Scenario: create user
    * def intUserId = call uuid1
    * def userEntityRequest = read('samples/user/user-entity-request.json')
    * userEntityRequest.barcode = extUserBarcode
    * userEntityRequest.patronGroup = karate.get('extGroupId', groupId)
    * userEntityRequest.id = karate.get('extUserId', intUserId)
    * userEntityRequest.personal.firstName = karate.get('firstName', 'firstName')
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

  @PostCheckOut
  Scenario: do check out
    * def intLoanDate = '2021-10-27T13:25:46.000Z'
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extCheckOutUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = extCheckOutItemBarcode
    * checkOutByBarcodeEntityRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkOutByBarcodeEntityRequest.loanDate = karate.get('extLoanDate', intLoanDate)
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201

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

  @CheckInItemError
  Scenario: check in item by barcode error
    * def checkInId = call uuid
    * def intCheckInDate = call read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')

    * def checkInRequest = read('classpath:vega/mod-circulation/features/samples/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = karate.get('extServicePointId', servicePointId)
    * checkInRequest.checkInDate = karate.get('extCheckInDate', intCheckInDate)
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 500

  @DeclareItemLost
  Scenario: init common data
    * def declareItemLostRequest = { declaredLostDateTime: #(declaredLostDateTime), servicePointId:#(servicePointId) }

    Given path 'circulation/loans/' + loanId + '/declare-item-lost'
    And request declareItemLostRequest
    When method POST
    Then status 204

  @PostRequest
  Scenario: create request
    * def intRequestType = "Recall"
    * def intRequestLevel = "Item"
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.requestType = karate.get('extRequestType', intRequestType)
    * requestEntityRequest.requestLevel = karate.get('extRequestLevel', intRequestLevel)
    * requestEntityRequest.instanceId = karate.get('extInstanceId')
    * requestEntityRequest.holdingsRecordId = karate.get('extHoldingsRecordId')
    * requestEntityRequest.pickupServicePointId = karate.get('extServicePointId', servicePointId)
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.id == requestId
    And match response.itemId == itemId
    And match response.requesterId == requesterId
    And match response.pickupServicePointId == karate.get('extServicePointId', servicePointId)
    And match response.status == 'Open - Not yet filled'

  @PostTitleLevelRequest
  Scenario: create title level request
    * def intRequestType = "Page"
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request/title-level-request-entity-request.json')
    * requestEntityRequest.id = requestId
    * requestEntityRequest.requestType = karate.get('extRequestType', intRequestType)
    * requestEntityRequest.pickupServicePointId = karate.get('extServicePointId', servicePointId)
    * requestEntityRequest.instanceId = karate.get('extInstanceId')
    Given path 'circulation', 'requests'
    And request requestEntityRequest
    When method POST
    Then status 201
    And match response.id == requestId
    And match response.requesterId == requesterId
    And match response.pickupServicePointId == karate.get('extServicePointId', servicePointId)
    And match response.status == 'Open - Not yet filled'
    And match response.requestLevel == 'Title'
    And match response.instanceId == karate.get('extInstanceId')

  @PostClaimItemReturned
  Scenario: claim item returned
    * def claimItemReturnedId = call uuid1
    * def claimItemReturnedRequest = read('classpath:vega/mod-circulation/features/samples/claim-item-returned-entity-request.json')

    Given path 'circulation/loans/' + loanId + '/claim-item-returned'
    And request claimItemReturnedRequest
    When method POST
    Then status 204

  @PostRefundFee
  Scenario: refund fee to patron
    * def refundFeeId = call uuid1
    * def refundFeeRequest = read('classpath:vega/mod-circulation/features/samples/feefine/refund-to-patron-entity-request.json')
    * refundFeeRequest.id = refundFeeId
    Given path 'feefineactions'
    And request refundFeeRequest
    When method POST
    Then  status 201

  @PutAccount
  Scenario: update account
    * def updateAccountRequest = read('classpath:vega/mod-circulation/features/samples/update-account-entity-request.json')
    Given path 'accounts/' + accountId
    And request updateAccountRequest
    When method PUT
    Then status 204

  @PostTlrConfig
  Scenario: create TLR configuration entry
    * def tlrConfigValue = read('classpath:vega/mod-circulation/features/samples/tlr-config.json')
    * tlrConfigValue.titleLevelRequestsFeatureEnabled = karate.get('extTitleLevelRequestsFeatureEnabled', true)
    * tlrConfigValue.tlrHoldShouldFollowCirculationRules = karate.get('extTlrHoldShouldFollowCirculationRules', false)
    * tlrConfigValue.createTitleLevelRequestsByDefault = karate.get('extCreateTitleLevelRequestsByDefault', false)
    * tlrConfigValue.confirmationPatronNoticeTemplateId = karate.get('extConfirmationPatronNoticeTemplateId', null)
    * tlrConfigValue.cancellationPatronNoticeTemplateId = karate.get('extCancellationPatronNoticeTemplateId', null)
    * tlrConfigValue.expirationPatronNoticeTemplateId = karate.get('extExpirationPatronNoticeTemplateId', null)

    * def tlrConfigEntry = read('classpath:vega/mod-circulation/features/samples/tlr-config-entry-request.json')
    * tlrConfigEntry.value = karate.toString(tlrConfigValue)
    Given path 'configurations/entries'
    And request tlrConfigEntry
    When method POST
    Then status 201

  @DeleteTlrConfig
  Scenario: delete TLR configuration entry
    * def tlrConfig = read('classpath:vega/mod-circulation/features/samples/tlr-config-entry-request.json')
    Given path 'configurations', 'entries', tlrConfig.id
    When method DELETE
    Then status 204

  @PostCancellationReason
  Scenario: create a cancellation reason
    * def cancellationReasonRequest = read('classpath:vega/mod-circulation/features/samples/cancellation-reason-entity-request.json')
    * cancellationReasonRequest.id = karate.get('extCancellationReasonId', cancellationReasonId)
    Given path 'cancellation-reason-storage', 'cancellation-reasons'
    And request cancellationReasonRequest
    When method POST
    Then status 201

  @PutPatronBlockConditionById
  Scenario: put patron block condition
    Given path 'patron-block-conditions/' + pbcId
    And request { id: '#(pbcId)', name:'#(pbcName)', message: '#(pbcMessage)', blockBorrowing: '#(blockBorrowing)', valueType:'Integer', blockRenewals: '#(blockRenewals)', blockRequests: '#(blockRequests)' }
    When method PUT
    Then status 204

  @PostPatronBlocksLimitsByConditionId
  Scenario: post patron block limit by condition id
    Given path 'patron-block-limits'
    And request { id: '#(id)', patronGroupId: '#(extGroupId)', conditionId: '#(pbcId)', value: '#(extValue)' }
    When method POST
    Then status 201

  @PostSettings
  Scenario: post create settings to enable checkOutLockFeature
    * def checkoutLockSettingsRequest = read('classpath:vega/mod-circulation/features/samples/checkout-Lock-settings-request.json')
    Given path 'settings/entries'
    And request checkoutLockSettingsRequest
    When method POST
    Then status 204
