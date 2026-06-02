Feature: Lender Transaction Renewal Policy

  Background:
    * url baseUrl
    * def proxyCall = karate.get('proxyCall', false)
    * def user = proxyCall == true ? testUser : testAdmin
    * print 'user  is', user
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def key = ''
    * configure headers = headersUser
    * callonce variables
    * def startDate = callonce getCurrentUtcDate
    * configure retry = { count: 10, interval: 2000 }
    * def txnId = '656317'
    * def itemId656317 = 'c6563170-0000-4000-a000-000000000001'
    * def itemBarcode656317 = 'C656317bc'
    * def loanPolicyId656317 = 'c6563171-0000-4000-a000-000000000001'
    * def patronId656317 = 'c6563172-0000-4000-a000-000000000001'
    * def patronBarcode656317 = 'FAT-656317-P'
    * def pickupSpName = 'sp-c656317'
    * def pickupLibCode = 'lib656317'

  @C656317
  Scenario: Create LENDER DCB transaction and verify renewalPolicy reflects loan renewals

    # Precondition: create item in Available status in Inventory
    * def itemReq = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemReq.id = itemId656317
    * itemReq.barcode = itemBarcode656317
    * itemReq.holdingsRecordId = holdingId
    * itemReq.materialType.id = intMaterialTypeId
    * itemReq.status.name = 'Available'
    Given path 'inventory', 'items'
    And request itemReq
    When method POST
    Then status 201

    # Precondition: create loan policy - Rolling, 1 hour, 2 renewals allowed, renew from current due date
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656317)",
      "name": "Loan Policy C656317",
      "loanable": true,
      "loansPolicy": {
        "profileId": "Rolling",
        "period": { "duration": 1, "intervalId": "Hours" },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
      },
      "renewable": true,
      "renewalsPolicy": {
        "unlimited": false,
        "numberAllowed": 2.0,
        "renewFromId": "CURRENT_DUE_DATE",
        "differentPeriod": false
      }
    }
    """
    When method POST
    Then status 201

    # Precondition: add patron-group circulation rule applying the new loan policy for patronGroupId
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId656317 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Step 1: Create DCB transaction with role = LENDER
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId656317
    * createReq.item.barcode = itemBarcode656317
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId656317
    * createReq.patron.barcode = patronBarcode656317
    * createReq.patron.group = patronGroupName
    * createReq.pickup.servicePointName = pickupSpName
    * createReq.pickup.libraryCode = pickupLibCode
    * createReq.role = 'LENDER'

    * def orgPath = '/transactions/' + txnId
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath
    * def orgPathStatus = '/transactions/' + txnId + '/status'
    * def newPathStatus = proxyCall == true ? proxyPath + orgPathStatus : orgPathStatus
    * def orgPathRenew = '/transactions/' + txnId + '/renew'
    * def newPathRenew = proxyCall == true ? proxyPath + orgPathRenew : orgPathRenew

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId656317
    And match $.patron.id == patronId656317

    # Step 2: Check in the item - item status becomes "In transit"
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode656317
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'

    # Step 3: Transition status to AWAITING_PICKUP
    * url baseUrlNew
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    # Step 4: Transition status to ITEM_CHECKED_OUT
    * def updateToCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToCheckedOutRequest
    When method PUT
    Then status 200

    # Step 5: Verify open loan exists for patron with renewalCount=0 (field absent when zero per FOLIO loan-storage behaviour)
    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '(itemId = ' + itemId656317 + ')'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match $.loans[0].userId == patronId656317

    # Step 6: First renewal via DCB renew endpoint
    * url baseUrlNew
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 200
    And match $.item.renewalInfo.renewalCount == 1
    And match $.item.renewalInfo.renewalMaxCount == 2
    And match $.item.renewalInfo.renewable == true

    # Step 7: Verify loan renewalCount=1 in loan-storage
    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '(itemId = ' + itemId656317 + ')'
    When method GET
    Then status 200
    And match $.loans[0].renewalCount == 1

    # Step 8: Second renewal via DCB renew endpoint
    * url baseUrlNew
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 200
    And match $.item.renewalInfo.renewalCount == 2
    And match $.item.renewalInfo.renewalMaxCount == 2
    And match $.item.renewalInfo.renewable == true

    # Step 8: Verify loan renewalCount=2 in loan-storage
    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '(itemId = ' + itemId656317 + ')'
    When method GET
    Then status 200
    And match $.loans[0].renewalCount == 2

    # Step 9: Third renewal attempt - max renewals reached, expected 422 with "loan at maximum renewal number"
    * url baseUrlNew
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 422
    And match $.errors[0].message contains 'loan at maximum renewal number'

    # Step 10: Verify loan renewalCount unchanged at 2 after failed renewal
    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '(itemId = ' + itemId656317 + ')'
    When method GET
    Then status 200
    And match $.loans[0].renewalCount == 2
