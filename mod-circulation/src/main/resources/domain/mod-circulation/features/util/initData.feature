Feature: init data for mod-circulation

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @PostInstance
  Scenario: create instance
    * def instanceTypeId = call uuid1
    * def contributorNameTypeId = call uuid1

    * def instanceTypeEntityRequest = read('samples/instance/instance-type-entity-request.json')
    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/instance/contributor-name-type-entity-request.json')
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('samples/instance/instance-entity-request.json')
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

  @PostServicePoint
  Scenario: create service point
    * def servicePointEntityRequest = read('samples/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

  @PostLocation
  Scenario: create location
    * def institutionId = call uuid1
    * def campusId = call uuid1
    * def libraryId = call uuid1

    * def locationUnitInstitutionEntityRequest = read('samples/location/location-unit-institution-entity-request.json')
    Given path 'location-units', 'institutions'
    And request locationUnitInstitutionEntityRequest
    When method POST
    Then status 201

    * def locationUnitCampusEntityRequest = read('samples/location/location-unit-campus-entity-request.json')
    Given path 'location-units', 'campuses'
    And request locationUnitCampusEntityRequest
    When method POST
    Then status 201

    * def locationUnitLibraryEntityRequest = read('samples/location/location-unit-library-entity-request.json')
    Given path 'location-units', 'libraries'
    And request locationUnitLibraryEntityRequest
    When method POST
    Then status 201

    * def locationEntityRequest = read('samples/location/location-entity-request.json')
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
    * def materialTypeLocalId = call uuid1

    * def permanentLoanTypeEntityRequest = read('samples/item/permanent-loan-type-entity-request.json')
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def materialTypeEntityRequest = read('samples/item/material-type-entity-request.json')
    * materialTypeEntityRequest.id = karate.get('varMaterialTypeId', materialTypeLocalId)
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item/item-entity-request.json')
    * itemEntityRequest.barcode = varItemBarcode
    * itemEntityRequest.materialType.id = karate.get('varMaterialTypeId', materialTypeId)
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

  @PostLoanPolicy
  Scenario: create loan policy
    * def loanLocalId = call uuid1

    * def loanPolicyEntityRequest = read('samples/policies/loan-policy-entity-request.json')
    * loanPolicyEntityRequest.id = karate.get('varLoanPolicyId', loanLocalId)
    * loanPolicyEntityRequest.name = loanPolicyEntityRequest.name + ' ' + random_string()
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicyEntityRequest
    When method POST
    Then status 201

  @PostLostPolicy
  Scenario: create lost policy
    * def lostItemLocalId = call uuid1

    * def lostItemFeePolicyEntityRequest = read('samples/policies/lost-item-fee-policy-entity-request.json')
    * lostItemFeePolicyEntityRequest.id = karate.get('varLostItemFeePolicyId', lostItemLocalId)
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicyEntityRequest
    When method POST
    Then status 201

  @PostOverduePolicy
  Scenario: create overdue policy
    * def overdueLocalId = call uuid1

    * def overdueFinePolicyEntityRequest = read('samples/policies/overdue-fine-policy-entity-request.json')
    * overdueFinePolicyEntityRequest.id = karate.get('varOverdueFinePoliciesId', overdueLocalId)
    * overdueFinePolicyEntityRequest.name = overdueFinePolicyEntityRequest.name + ' ' + random_string()
    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

  @PostPatronPolicy
  Scenario: create patron policy
    * def patronLocalId = call uuid1

    * def patronNoticePolicyEntityRequest = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.id = karate.get('varPatronPolicyId', patronLocalId)
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

  @PostRequestPolicy
  Scenario: create request policy
    * def requestLocalId = call uuid1

    * def policyEntityRequest = read('samples/policies/request-policy-entity-request.json')
    * policyEntityRequest.id = karate.get('varRequestPolicyId', requestLocalId)
    Given path 'request-policy-storage/request-policies'
    And request policyEntityRequest
    When method POST
    Then status 201

  @PostRulesWithMaterial
  Scenario: create policies with material
    * def rules = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + varLoanPolicyId + ' o ' + varOverdueFinePoliciesId + ' i ' + varLostItemFeePolicyId + ' r ' + varRequestPolicyId + ' n ' + varPatronPolicyId + '\nm ' + varMaterialTypeId + ':  l ' + varLoanPolicyMaterialId + ' o ' + varOverdueFinePoliciesMaterialId + ' i ' + varLostItemFeePolicyMaterialId + ' r ' + varRequestPolicyMaterialId + ' n ' + varPatronPolicyMaterialId
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
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def policyEntityRequest = read('samples/policies/request-policy-entity-request.json')
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
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

  @PostUser
  Scenario: create user
    * def userEntityRequest = read('samples/user/user-entity-request.json')
    * userEntityRequest.barcode = varUserBarcode
    * userEntityRequest.patronGroup = groupId
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

  @PostCheckOut
  Scenario: do check out
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = varCheckOutUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = varCheckOutItemBarcode
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201
