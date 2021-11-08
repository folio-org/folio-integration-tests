Feature: init data for mod-circulation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

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
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('samples/service-point-entity-request.json')
    * servicePointEntityRequest.name = servicePointEntityRequest.name + ' ' + random_string()
    * servicePointEntityRequest.code = servicePointEntityRequest.code + ' ' + random_string()
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PostOwner
  Scenario: create owner
    * def ownerEntityRequest = read('samples/owner-entity-request.json')

    Given path 'owners'
    And request ownerEntityRequest
    When method POST
    Then status 201

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
    * locationEntityRequest.institutionId = karate.get('extInstitutionId', intInstitutionId)
    * locationEntityRequest.campusId = karate.get('extCampusId', intCampusId)
    * locationEntityRequest.libraryId = karate.get('extLibraryId', intLibraryId)
    * locationEntityRequest.name = locationEntityRequest.name + ' ' + random_string()
    * locationEntityRequest.code = locationEntityRequest.code + ' ' + random_string()
    Given path 'locations'
    And request locationEntityRequest
    When method POST
    Then status 201

  @PostHoldings
  Scenario: create holdings
    * def holdingsEntityRequest = read('samples/holdings-entity-request.json')
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

  @PostItem
  Scenario: create item
    * def permanentLoanTypeId = call uuid1
    * def intMaterialTypeId = call uuid1
    * def intItemId = call uuid1

    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    * permanentLoanTypeEntityRequest.name = permanentLoanTypeEntityRequest.name + ' ' + random_string()
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('extMaterialTypeId', intMaterialTypeId)
    * materialTypeEntityRequest.name = materialTypeEntityRequest.name + ' ' + random_string()
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = extItemBarcode
    * itemEntityRequest.id = karate.get('extItemId', intItemId)
    * itemEntityRequest.materialType.id = karate.get('extMaterialTypeId', intMaterialTypeId)
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

  @PostLostPolicy
  Scenario: create lost policy
    * def intLlostItemPolicyId = call uuid1

    * def lostItemFeePolicyEntityRequest = read('samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.id = karate.get('extLostItemFeePolicyId', intLlostItemPolicyId)
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

    * def requestPolicyEntityRequest = read('samples/policies/request-policy-entity-request.json')
    * requestPolicyEntityRequest.id = karate.get('extRequestPolicyId', intRequestPolicyId)
    * requestPolicyEntityRequest.name = requestPolicyEntityRequest.name + ' ' + random_string()
    Given path 'request-policy-storage/request-policies'
    And request requestPolicyEntityRequest
    When method POST
    Then status 201

  @PostRulesWithMaterialType
  Scenario: create policies with material
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + extLoanPolicyId + ' o ' + extOverdueFinePoliciesId + ' i ' + extLostItemFeePolicyId + ' r ' + extRequestPolicyId + ' n ' + extPatronPolicyId + '\nm ' + extMaterialTypeId + ':  l ' + extLoanPolicyMaterialId + ' o ' + extOverdueFinePoliciesMaterialId + ' i ' + extLostItemFeePolicyMaterialId + ' r ' + extRequestPolicyMaterialId + ' n ' + extPatronPolicyMaterialId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

  @PostPolicies
  Scenario: create policies
    * def loanPolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1

    * def loanPolicyEntityRequest = read('samples/policies/loan-policy-entity-request.json')
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

    * def lostItemFeePolicyEntityRequest = read('samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.name = lostItemFeePolicyEntityRequest.name + ' ' + random_string()
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

    * def overdueFinePolicyEntityRequest = read('samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' ' + random_string()
    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

    * def patronNoticePolicyEntityRequest = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.name = patronNoticePolicyEntityRequest.name + ' ' + random_string()
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def policyEntityRequest = read('samples/policies/request-policy-entity-request.json')
    * policyEntityRequest.name = policyEntityRequest.name + ' ' + random_string()
    Given path 'request-policy-storage/request-policies'
    And request policyEntityRequest
    When method POST
    Then status 201

    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronPolicyId
    * def rulesEntityRequest = { "rulesAsText": "#(rules)" }
    Given path 'circulation-rules-storage'
    And request rulesEntityRequest
    When method PUT
    Then status 204

  @PostGroup
  Scenario: create group
    * def groupEntityRequest = read('samples/user/group-entity-request.json')
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
    * userEntityRequest.patronGroup = groupId
    * userEntityRequest.id = karate.get('extUserId', intUserId)
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

  @PostCheckOut
  Scenario: do check out
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extCheckOutUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = extCheckOutItemBarcode
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201

  @CheckInItem
  Scenario: check in item by barcode
    * def checkInId = call uuid
    * def getDate = read('classpath:domain/mod-circulation/features/util/get-time-now-function.js')
    * def checkInDate = getDate()

    * def checkInRequest = read('classpath:domain/mod-circulation/features/samples/check-in-by-barcode-entity-request.json')
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.barcode == itemBarcode
    And match $.loan.action == 'checkedin'
    And match $.loan.status.name == 'Closed'

  @DeclareItemLost
  Scenario: init common data
    * def declareItemLostRequest = { declaredLostDateTime: #(declaredLostDateTime), servicePointId:#(servicePointId) }

    Given path 'circulation/loans/' + loanId + '/declare-item-lost'
    And request declareItemLostRequest
    When method POST
    Then status 204
    
