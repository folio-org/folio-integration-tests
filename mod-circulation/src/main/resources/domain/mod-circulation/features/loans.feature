Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def materialTypeId = call uuid1
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }

    * def loanPolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * callonce read('classpath:domain/mod-circulation/features/util/initData.feature@PostRulesWithMaterialType') { extLoanPolicyId: #(loanPolicyId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extPatronPolicyId: #(patronPolicyId), extRequestPolicyId: #(requestPolicyId), extMaterialTypeId: #(materialTypeId), extLoanPolicyMaterialId: #(loanPolicyMaterialId), extOverdueFinePoliciesMaterialId: #(overdueFinePoliciesId), extLostItemFeePolicyMaterialId: #(lostItemFeePolicyId), extRequestPolicyMaterialId: #(requestPolicyId), extPatronPolicyMaterialId: #(patronPolicyId) }

    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def itemId = call uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def userBarcode = random(100000)
    * def checkOutByBarcodeId = call uuid1
    * def parseObjectToDate = read('classpath:domain/mod-circulation/features/util/parse-object-to-date-function.js')

  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched
    * def extUserId = call uuid1

    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: 666666, extMaterialTypeId: #(materialTypeId), extItemId: #(itemId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(userBarcode) }

    # checkOut
    * def checkOutResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: 666666 }

    # get loan and verify
    Given path 'circulation', 'loans'
    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + itemId + ')'
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
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '555555', extMaterialTypeId: #(materialTypeId), extItemId: #(itemId) }
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

  Scenario: When get loans for a patron is called, return a paged collection of loans for that patron with all data as specified in the circulation/loans API

    * def extUserId = call uuid1
    * def extItemBarcode1 = random(10000)
    * def extItemBarcode2 = random(10000)
    * def extUserBarcode = random(100000)

    # post items
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode1), extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode2), extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # checkOut the first item
    * def checkOutResponse1 = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
    # checkOut the second item
    * def checkOutResponse2 = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode2) }

    # Get a paged collection of patron
    Given path 'circulation', 'loans'
    And param query = '(userId=="' + extUserId + '")'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, loans: #present }
    And match response.totalRecords == 2
    And match response.loans[0] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[0].id == checkOutResponse1.response.id
    And match response.loans[1] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[1].id == checkOutResponse2.response.id

  Scenario: When an existing loan is declared lost, update declaredLostDate, item status to declared lost and bill lost item fees per the Lost Item Fee Policy
    * def itemBarcode = random(100000)
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * def postServicePointResult = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * def servicePointId = postServicePointResult.response.id
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResult = call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(itemBarcode), extMaterialTypeId: #(materialTypeId) }
    * def itemId = postItemResult.response.id
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

    * def groupId = call uuid1
    * def extInstanceTypeId = call uuid1
    * def extInstitutionId = call uuid1
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1
    * def requestId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extUserId2 = call uuid1
    * def expectedLoanDate = '2021-10-27T13:25'
    * def expectedDueDateBeforeRequest = '2021-11-17T13:25'

    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation') { extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '333333', extMaterialTypeId: #(materialTypeId), extItemId: #(extItemId) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: '44441' }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: '44442' }

    # checkOut an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: '44441', extCheckOutItemBarcode: '333333' }

    # check loan and dueDateChangedByRecall availability
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + extItemId
    When method GET
    Then status 200
    * def loanResponse = response.loans[0]
    Then match loanResponse.dueDateChangedByRecall == '#notpresent'
    Then match loanResponse.loanPolicyId == loanPolicyMaterialId
    Then match loanResponse.loanDate contains expectedLoanDate
    Then match loanResponse.dueDate contains expectedDueDateBeforeRequest

    # post recall request by patron-requester
    * def requestEntityRequest = read('classpath:domain/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId2
    * requestEntityRequest.itemId = extItemId
    Given path 'circulation' ,'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # check loan and dueDateChangedByRecall availability after request
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + extItemId
    When method GET
    Then status 200
    Then match $.loans[0].dueDateChangedByRecall == true
    And match $.loans[0].dueDate !contains expectedDueDateBeforeRequest

  Scenario: When an loaned item is checked in at a service point that serves its location and no request exists, change the item status to Available

    * def extItemBarcode = 'fat1003-ibc'
    * def extUserId = call uuid1
    * def extUserBarcode = 'fat1003-ubc'

    # location and service point setup
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode)}

    # post a user
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # check-out the item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # verify that no request exist before check-in
    Given path 'circulation', 'requests'
    And param query = '(requesterId==' + extUserId + ' and status=="Open*")'
    When method GET
    Then status 200
    And match response.totalRecords == 0
    And match response.requests == []

    # check-in the item and verify that item status is changed to 'Available'
    * def checkInResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    * def item = checkInResponse.response.item
    And match item.id == itemId
    And match item.status.name == 'Available'

  Scenario: When an requested loaned item is checked in at a service point designated as the pickup location of the request, change the item status to awaiting-pickup

    * def extItemBarcode = '12123366'
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = '3315666'
    * def extUserBarcode2 = '3315669'
    * def extRequestId = call uuid1

    # post a location and service point
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation')

    # post an item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode)}

    # post an user
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode1), extUserId: #(extUserId1) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode2), extUserId: #(extUserId2) }

    # checkOut the item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode) }

    # post a request for the checked-out-item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(itemId), requesterId: #(extUserId2) }

    # checkIn the item and check if the request status changed to awaiting pickup
    * def checkInResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    * def response = checkInResponse.response
    And match response.item.id == itemId
    And match response.item.status.name == 'Awaiting pickup'

    # check the status of the user request whether changed to 'Open-Awaiting pickup'
    Given path 'circulation', 'requests', extRequestId
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

  Scenario:  When a loaned item is checked in at a service point that does not serve its location and no request exists, change the item status to In-transit and destination to primary service point for its location

    * def extItemBarcode = 'fat1004-ibc'
    * def extUserId = call uuid1
    * def extUserBarcode = 'fat1004-ubc'
    * def extServicePointId1 = call uuid1
    * def extServicePointId2 = call uuid1
    * def extInstitutionId1 = call uuid1
    * def extInstitutionId2 = call uuid1
    * def extCampusId1 = call uuid1
    * def extCampusId2 = call uuid1
    * def extLibraryId1 = call uuid1
    * def extLibraryId2 = call uuid1
    * def extLocationId1 = call uuid1
    * def extLocationId2 = call uuid1

    # first location and service point setup
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1),  extInstitutionId: #(extInstitutionId1), extCampusId: #(extCampusId1), extLibraryId: #(extLibraryId1), extServicePointId: #(extServicePointId1) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId1) }

    # second location and service point setup
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extInstitutionId: #(extInstitutionId2), extCampusId: #(extCampusId2), extLibraryId: #(extLibraryId2), extServicePointId: #(extServicePointId2) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId2) }

    # post an item which is located in the first location
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostHoldings') { extLocationId: #(extLocationId1) }
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }

    # post a user
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # check-out the item
    * call read('classpath:domain/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId1) }

    # verify that no request exist before check-in
    Given path 'circulation', 'requests'
    And param query = '(requesterId==' + extUserId + ' and status=="Open*")'
    When method GET
    Then status 200
    And match response.totalRecords == 0
    And match response.requests == []

    # check-in the item from second service point and verify that item status is changed to 'In transit'
    * def checkInResponse = call read('classpath:domain/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId2) }
    * def item = checkInResponse.response.item
    And match item.id == itemId
    And match item.status.name == 'In transit'
    And match item.inTransitDestinationServicePointId == extServicePointId1
