Feature: Lender Transaction Non-Renewable Loan Policy

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
    * def txnId = '656300'
    * def itemId656300 = 'c6563001-0000-4000-a000-000000000001'
    * def itemBarcode656300 = 'C656300bc'
    * def patronId656300 = 'c6563002-0000-4000-a000-000000000001'
    * def patronBarcode656300 = 'FAT-C656300-P'
    * def loanPolicyId656300 = 'c6563000-0000-4000-a000-000000000001'
    * def pickupSpName = 'sp-c656300'
    * def pickupLibCode = 'lib656300'

  @C656300
  Scenario: Create LENDER DCB transaction with non-renewable loan policy and verify renewal is blocked

    # Precondition: create item in Available status in Inventory
    * def itemReq = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemReq.id = itemId656300
    * itemReq.barcode = itemBarcode656300
    * itemReq.holdingsRecordId = holdingId
    * itemReq.materialType.id = intMaterialTypeId
    * itemReq.status.name = 'Available'
    Given path 'inventory', 'items'
    And request itemReq
    When method POST
    Then status 201

    # Precondition: create loan policy - Rolling, 1 week, not renewable
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656300)",
      "name": "Loan Policy C656300",
      "loanable": true,
      "loansPolicy": {
        "profileId": "Rolling",
        "period": { "duration": 1, "intervalId": "Weeks" },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
      },
      "renewable": false
    }
    """
    When method POST
    Then status 201

    # Precondition: set circulation rule applying the non-renewable loan policy for patronGroupId
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId656300 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Step 1: Create DCB transaction with role = LENDER
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId656300
    * createReq.item.barcode = itemBarcode656300
    * createReq.patron.id = patronId656300
    * createReq.patron.barcode = patronBarcode656300
    * createReq.patron.group = patronGroupName
    * createReq.pickup.servicePointName = pickupSpName
    * createReq.pickup.libraryCode = pickupLibCode
    * createReq.role = 'LENDER'

    * def orgPath = '/transactions/' + txnId
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath
    * def orgPathStatus = '/transactions/' + txnId + '/status'
    * def newPathStatus = proxyCall == true ? proxyPath + orgPathStatus : orgPathStatus

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId656300
    And match $.patron.id == patronId656300

    # Step 2: Check in the item - item moves to "In transit", transaction moves to OPEN
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode656300
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'

    # Wait for transaction status to become OPEN after check-in
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    # Step 3: Update transaction status to AWAITING_PICKUP
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    # Step 4: Update transaction status to ITEM_CHECKED_OUT
    * def updateToCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToCheckedOutRequest
    When method PUT
    Then status 200

    # Step 5: Verify transaction is ITEM_CHECKED_OUT and open loan exists for the shadow patron
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'ITEM_CHECKED_OUT'
    When method GET
    Then status 200

    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '( itemId = ' + itemId656300 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId656300

    # Step 6: Attempt renewal via DCB renew endpoint - expect 422 as loan is not renewable
    * url baseUrlNew
    * def orgPathRenew = '/transactions/' + txnId + '/renew'
    * def newPathRenew = proxyCall == true ? proxyPath + orgPathRenew : orgPathRenew
    Given path newPathRenew
    And param apikey = key
    And request {}
    When method PUT
    Then status 422
    And match $.errors[0].message contains 'loan is not renewable'

    # Step 7: Verify loan is still unchanged - totalRecords still 1, renewalCount absent (= 0)
    * url baseUrl
    Given path 'loan-storage', 'loans'
    And param query = '( itemId = ' + itemId656300 + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId656300
