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
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: 666666, extMaterialTypeId: #(materialTypeId), extItemId: #(itemId) }
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
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '555555', extItemId: #(itemId) }
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

  Scenario: When get loans for a patron is called, return a paged collection of loans for that patron with all data as specified in the circulation/loans API

    * def extItemBarcode1 = random(10000)
    * def extItemBarcode2 = random(10000)
    * def extUserBarcode = random(100000)

    # post items
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode1) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode2) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPolicies')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # checkOut the first item
    * def checkOutResponse1 = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
    # checkOut the second item
    * def checkOutResponse2 = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode2) }

    # Get a paged collection of patron
    Given path 'circulation', 'loans'
    And param query = '(userId=="' + userId + '")'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, loans: #present }
    And match response.totalRecords == 2
    And match response.loans[0] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[0].id == checkOutResponse1.response.id
    And match response.loans[1] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[1].id == checkOutResponse2.response.id

