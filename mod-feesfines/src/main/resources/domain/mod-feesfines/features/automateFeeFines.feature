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
    * def accountId = call uuid1
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
    * def requestInstanceTypeEntity = read('samples/instance-type-request-entity.json')
    Given path 'instance-types'
    And request requestInstanceTypeEntity
    When method POST
    Then status 201

    * def requestContributorNameTypeEntity = read('samples/instance-type-request-entity.json')
    Given path 'contributor-name-types'
    And request requestContributorNameTypeEntity
    When method POST
    Then status 201

    * def requestInstanceEntity = read('samples/instance-request-entity.json')
    Given path 'inventory', 'instances'
    And request requestInstanceEntity
    When method POST
    Then status 201


    # location and its prerequisites
    * def requestServicePointEntity = read('samples/service-point-request-entity.json')
    Given path 'service-points'
    And request requestServicePointEntity
    When method POST
    Then status 201

    * def requestLocationUnitInstitutionEntity = read('samples/location/location-unit-institution-request-entity.json')
    Given path 'location-units', 'institutions'
    And request requestLocationUnitInstitutionEntity
    When method POST
    Then status 201

    * def requestLocationUnitCampusEntity = read('samples/location/location-unit-campus-request-entity.json')
    Given path 'location-units', 'campuses'
    And request requestLocationUnitCampusEntity
    When method POST
    Then status 201

    * def requestLocationUnitLibraryEntity = read('samples/location/location-unit-library-request-entity.json')
    Given path 'location-units', 'libraries'
    And request requestLocationUnitLibraryEntity
    When method POST
    Then status 201

    * def requestLocationEntity = read('samples/location/location-request-entity.json')
    Given path 'locations'
    And request requestLocationEntity
    When method POST
    Then status 201


    # holding
    * def requestHoldingEntity = read('samples/holding-request-entity.json')
    Given path 'holdings-storage', 'holdings'
    And request requestHoldingEntity
    When method POST
    Then status 201


    # item and its prerequisites
    * def requestPermanentLoanTypeEntity = read('samples/permanent-loan-type-request-entity.json')
    Given path 'loan-types'
    And request requestPermanentLoanTypeEntity
    When method POST
    Then status 201

    * def requestMaterialTypeEntity = read('samples/material-type-request-entity.json')
    Given path 'material-types'
    And request requestMaterialTypeEntity
    When method POST
    Then status 201

    * def requestItemEntity = read('samples/item-request-entity.json')
    Given path 'inventory', 'items'
    And request requestItemEntity
    When method POST
    Then status 201

    #policies
    * def loanPolicy = read('samples/policies/loan-policy-request-entity.json')
    Given path 'loan-policy-storage/loan-policies'
    And request loanPolicy
    When method POST
    Then status 201

    * def lostItemFeePolicy = read('samples/policies/lost-item-fee-policy-request-entity.json')
    Given path 'lost-item-fees-policies'
    And request lostItemFeePolicy
    When method POST
    Then status 201

    * def overdueFinePolicy = read('samples/policies/overdue-fine-policy-request-entity.json')
    Given path 'overdue-fines-policies'
    And request overdueFinePolicy
    When method POST
    Then status 201

    * def patronNoticePolicy = read('samples/policies/patron-notice-policy-request-entity.json')
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request patronNoticePolicy
    When method POST
    Then status 201

    * def requestPolicy = read('samples/policies/request-policy-request-entity.json')
    Given path 'request-policy-storage/request-policies'
    And request requestPolicy
    When method POST
    Then status 201

    * def priorityVariable = 'priority: t, s, c, b, a, m, g fallback-policy: l ' + loanPolicyId + ' o ' + overdueFinePoliciesId + ' i ' + lostItemFeePolicyId + ' r ' + requestPolicyId + ' n ' + patronPolicyId
    * def rulesRequestEntity = { "rulesAsText": "#(priorityVariable)" }
    Given path 'circulation-rules-storage'
    And request rulesRequestEntity
    When method PUT
    Then status 204


    # user and its prerequisites
    * def ownerRequestEntity = read('samples/owner-request-entity.json')
    Given path 'owners'
    And request ownerRequestEntity
    When method POST
    Then status 201

    * def feefineTypeRequestEntity = read('samples/feefine-request-entity.json')
    * feefineTypeRequestEntity.automatic = true
    * feefineTypeRequestEntity.feeFineType = "Overdue fine"
    * feefineTypeRequestEntity.defaultAmount = null
    Given path 'feefines'
    And request feefineTypeRequestEntity
    When method POST
    Then status 201

    * def groupRequestEntity = read('samples/group-request-entity.json')
    Given path 'groups'
    And request groupRequestEntity
    When method POST
    Then status 201

    * def userRequestEntity = read('samples/user-request-entity.json')
    * userRequestEntity.barcode = 55555
    * userRequestEntity.patronGroup = groupId
    Given path 'users'
    And request userRequestEntity
    When method POST
    Then status 201


    # checkOut\checkIn
    * def checkOutByBarcodeRequestEntity = read('samples/check-out-by-barcode-request-entity.json')
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeRequestEntity
    When method POST
    Then status 201

    * def checkInByBarcodeRequestEntity = read('samples/check-in-by-barcode-request-entity.json')
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInByBarcodeRequestEntity
    When method POST
    Then status 200


    #make changes in contributor's field
    Given path 'accounts'
    When method GET
    * def constantResult = response.accounts[0].id

    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.contributorNames[0] == { "name": "Chambers, Becky" }

    Given path 'inventory', 'instances'
    When method GET
    Then status 200
    * def instanceResponse = response.instances[0]

    * instanceResponse.contributors = [{ "contributorNameTypeId": contributorNameTypeId,  "name": "changed name" }]
    Given path 'inventory', 'instances', instanceId
    And request instanceResponse
    When method PUT
    Then status 204


    #check after changes
    Given path 'inventory', 'items', itemId
    When method GET
    Then status 200
    And match response.contributorNames[0] == { "name": "changed name" }

    Given path 'accounts', constantResult
    When method GET
    Then status 200
    And match response.contributors[0] == { "name": "Chambers, Becky" }

