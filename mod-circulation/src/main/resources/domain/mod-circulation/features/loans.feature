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
    * def userBarcode = random(100000)
    * def checkOutByBarcodeId = call uuid1
    * def parseObjectToDate = read('classpath:domain/mod-circulation/features/util/parse-object-to-date-function.js')

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
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode) }

    # checkOut
    * def checkOutResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: 666666 }

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
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode)  }

    # checkOut an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: '555555' }

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

    Scenario: When an existing loan is declared lost, update declaredLostDate, item status to declared lost and bill lost item fees per the Lost Item Fee Policy
      * def itemBarcode = random(100000)
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
      * def postServicePointResult = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
      * def servicePointId = postServicePointResult.response.id
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostOwner') { servicePointId: #(servicePointId) }
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
      * def postItemResult = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(itemBarcode), extMaterialTypeId: #(materialTypeId) }
      * def itemId = postItemResult.response.id
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPolicies')
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode) }

      * def checkOutResult = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: #(itemBarcode) }
      * def loanId = checkOutResult.response.id
      * def declaredLostDateTime = call read('classpath:domain/mod-circulation/features/util/get-time-now-function.js')
      * call read('classpath:domain/mod-circulation/features/util/initData.feature@DeclareItemLost') { servicePointId: #(servicePointId), loanId: #(loanId), declaredLostDateTime:#(declaredLostDateTime) }

      Given path '/loan-storage', 'loans', loanId
      When method GET
      Then status 200
      And match parseObjectToDate(response.declaredLostDate) == parseObjectToDate(declaredLostDateTime)

      Given path '/item-storage', 'items', itemId
      When method GET
      Then status 200
      And match response.status.name == 'Declared lost'

      * def lostItemFeePolicyEntity = read('samples/policies/lost-item-fee-policy-entity-request.json')
      Given path 'accounts'
      And param query = 'loanId==' + loanId + ' and feeFineType==Lost item processing fee'
      When method GET
      Then status 200
      And match response.accounts[0].amount == lostItemFeePolicyEntity.lostItemProcessingFee

      Given path 'accounts'
      And param query = 'loanId==' + loanId + ' and feeFineType==Lost item fee'
      When method GET
      Then status 200
      And match response.accounts[0].amount == lostItemFeePolicyEntity.chargeAmountItem.amount

  Scenario: Post item, two patrons, check out item and post a recall request, assert expectedDueDateBeforeRequest and dueDate

    * def materialTypeId = call uuid1
    * def groupId = call uuid1
    * def extInstanceTypeId = call uuid1
    * def extInstitutionId = call uuid1
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1
    * def requestId = call uuid1
    * def loanPolicyId = call uuid1
    * def recallReturnIntervalLoanPolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def extUserId = call uuid1
    * def extUserId2 = call uuid1
    * def expectedLoanDate = '2021-10-27T13:25'
    * def expectedDueDateBeforeRequest = '2021-11-17T13:25'

    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation') { extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '333333', extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: '44441' }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: '44442' }

    # postLoanPolicy with recallReturnInterval setting
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(recallReturnIntervalLoanPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRulesWithMaterialType') { extLoanPolicyId: #(loanPolicyId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extPatronPolicyId: #(patronPolicyId), extRequestPolicyId: #(requestPolicyId), extMaterialTypeId: #(materialTypeId), extLoanPolicyMaterialId: #(recallReturnIntervalLoanPolicyId), extOverdueFinePoliciesMaterialId: #(overdueFinePoliciesId), extLostItemFeePolicyMaterialId: #(lostItemFeePolicyId), extRequestPolicyMaterialId: #(requestPolicyId), extPatronPolicyMaterialId: #(patronPolicyId) }

    # checkOut an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: '44441', extCheckOutItemBarcode: '333333' }

    # check loan and dueDateChangedByRecall availability
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + itemId
    When method GET
    Then status 200
    * def loanResponse = response.loans[0]
    Then match loanResponse.dueDateChangedByRecall == '#notpresent'
    Then match loanResponse.loanPolicyId == recallReturnIntervalLoanPolicyId
    Then match loanResponse.loanDate contains expectedLoanDate
    Then match loanResponse.dueDate contains expectedDueDateBeforeRequest

    # post recall request by patron-requester
    * def requestEntityRequest = read('classpath:domain/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId2
    Given path 'circulation' ,'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # check loan and dueDateChangedByRecall availability after request
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + itemId
    When method GET
    Then status 200
    Then match $.loans[0].dueDateChangedByRecall == true
    And match $.loans[0].dueDate !contains expectedDueDateBeforeRequest
