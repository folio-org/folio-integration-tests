Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def materialTypeId = call uuid1
    * def itemId = call uuid1
    * def loanPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def checkOutByBarcodeId = call uuid1

  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched

    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: 666666, extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRulesWithMaterialType') { extLoanPolicyId: #(loanPolicyId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extPatronPolicyId: #(patronPolicyId), extRequestPolicyId: #(requestPolicyId), extMaterialTypeId: #(materialTypeId), extLoanPolicyMaterialId: #(loanPolicyMaterialId), extOverdueFinePoliciesMaterialId: #(overdueFinePoliciesId), extLostItemFeePolicyMaterialId: #(lostItemFeePolicyId), extRequestPolicyMaterialId: #(requestPolicyId), extPatronPolicyMaterialId: #(patronPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: 55555 }

    # checkOut
    * def checkOutResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: 55555, extCheckOutItemBarcode: 666666 }

    # get loan and verify
    Given path 'circulation', 'loans'
    And param query = '(userId==' + userId + ' and ' + 'itemId==' + itemId + ')'
    When method GET
    Then status 200
    And match response.loans[0].id == checkOutResponse.response.id
    And match response.loans[0].loanPolicyId == loanPolicyMaterialId

  Scenario: Get checkIns records, define current item checkIn record and its status

    * def extInstanceTypeId = call uuid1
    * def extInstitutionId = call uuid1
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1

    #post an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation') { extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '555555' }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPolicies')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: '77777' }

    # checkOut an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: '77777', extCheckOutItemBarcode: '555555' }

    # checkIn an item with certain itemBarcode
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: '555555' }

    # get check-ins and assert checkedIn record
    Given path 'check-in-storage', 'check-ins'
    When method GET
    Then status 200
    * def checkedInRecord = response.checkIns[response.totalRecords - 1]
    And match checkedInRecord.itemId == itemId

    Given path 'check-in-storage', 'check-ins', checkedInRecord.id
    When method GET
    Then status 200
    And match response.itemStatusPriorToCheckIn == 'Checked out'
    And match response.itemId == itemId
