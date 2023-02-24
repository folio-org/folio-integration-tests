Feature: automate fee/fines

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def mockLoanId = call uuid1
    * def userId = call uuid1
    * def groupId = call uuid1
    * def feefineId = call uuid1
    * def ownerId = call uuid1
    * def instanceTypeId = call uuid1
    * def contributorNameTypeId = call uuid1
    * def instanceId = call uuid1
    * def holdingId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def institutionId = call uuid1
    * def campusId = call uuid1
    * def libraryId = call uuid1
    * def itemId = call uuid1
    * def permanentLoanTypeId = call uuid1
    * def materialTypeId = call uuid1
    * def checkOutByBarcodeId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def loanPolicyId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1

  Scenario: verify Account.contributors field

    # instance and its prerequisites

    * def instanceTypeEntityRequest = read('samples/instance-type-entity-request.json')
    Given path 'instance-types'
    And request instanceTypeEntityRequest
    When method POST
    Then status 201

    * def contributorNameTypeEntityRequest = read('samples/contributor-name-type-entity-request.json')
    * contributorNameTypeEntityRequest.name = 'CN-FAT-4547'
    Given path 'contributor-name-types'
    And request contributorNameTypeEntityRequest
    When method POST
    Then status 201

    * def instanceEntityRequest = read('samples/instance-entity-request.json')
    Given path 'inventory', 'instances'
    And request instanceEntityRequest
    When method POST
    Then status 201

    # location and its prerequisites

    * def servicePointEntityRequest = read('samples/service-point-entity-request.json')
    Given path 'service-points'
    And request servicePointEntityRequest
    When method POST
    Then status 201

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

    # holding

    * def holdingsEntityRequest = read('samples/holdings-entity-request.json')
    Given path 'holdings-storage', 'holdings'
    And request holdingsEntityRequest
    When method POST
    Then status 201

    # item and its prerequisites

    * def permanentLoanTypeEntityRequest = read('samples/permanent-loan-type-entity-request.json')
    Given path 'loan-types'
    And request permanentLoanTypeEntityRequest
    When method POST
    Then status 201

    * def materialTypeEntityRequest = read('samples/material-type-entity-request.json')
    Given path 'material-types'
    And request materialTypeEntityRequest
    When method POST
    Then status 201

    * def itemEntityRequest = read('samples/item-entity-request.json')
    Given path 'inventory', 'items'
    And request itemEntityRequest
    When method POST
    Then status 201

    # policies

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
    * overdueFinePolicyEntityRequest.name = "overdue test name"
    Given path 'overdue-fines-policies'
    And request overdueFinePolicyEntityRequest
    When method POST
    Then status 201

    * def patronNoticePolicyEntityRequest = read('samples/policies/patron-notice-policy-entity-request.json')
    * patronNoticePolicyEntityRequest.name = 'PPN-FAT-4547'
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicyEntityRequest
    When method POST
    Then status 201

    * def policyEntityRequest = read('samples/policies/request-policy-entity-request.json')
    * policyEntityRequest.name = 'PER-FAT-4547'
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

    # feefine settings

    * def ownerEntityRequest = read('samples/owner-entity-request.json')
    Given path 'owners'
    And request ownerEntityRequest
    When method POST
    Then status 201

    * def feefineTypeEntityRequest = read('samples/feefine-request-entity.json')
    * feefineTypeEntityRequest.automatic = true
    * feefineTypeEntityRequest.feeFineType = "Overdue fine"
    * feefineTypeEntityRequest.defaultAmount = null
    Given path 'feefines'
    And request feefineTypeEntityRequest
    When method POST
    Then status 201

    # user and its prerequisites

    * def groupEntityRequest = read('samples/group-entity-request.json')
    Given path 'groups'
    And request groupEntityRequest
    When method POST
    Then status 201

    * def userEntityRequest = read('samples/user-request-entity.json')
    * userEntityRequest.barcode = 55555
    * userEntityRequest.patronGroup = groupId
    Given path 'users'
    And request userEntityRequest
    When method POST
    Then status 201

    # checkOut\checkIn

    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 201

    * def checkInByBarcodeEntityRequest = read('samples/check-in-by-barcode-entity-request.json')
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInByBarcodeEntityRequest
    When method POST
    Then status 200

    # make changes in contributor's field

    Given path 'accounts'
    And param query = 'userId==' + userId
    When method GET
    * def constantResult = response.accounts[0].id

    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.contributorNames[0] == { "name": "Chambers, Becky" }

    Given path 'inventory', 'instances'
    When method GET
    Then status 200
    * def instanceResponse = response.instances.find(instance => instance.id == instanceId)
    * instanceResponse.contributors = [{ "contributorNameTypeId": contributorNameTypeId,  "name": "changed name" }]

    Given path 'inventory', 'instances', instanceId
    And request instanceResponse
    When method PUT
    Then status 204

    # check after changes

    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.contributorNames[0] == { "name": "changed name" }

    Given path 'accounts', constantResult
    When method GET
    Then status 200
    And match response.contributors[0] == { "name": "Chambers, Becky" }

