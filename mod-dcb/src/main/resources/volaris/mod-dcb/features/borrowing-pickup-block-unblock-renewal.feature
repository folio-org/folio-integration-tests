Feature: BORROWING-PICKUP Transaction Block and Unblock Renewal

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
    * def txnId = '919910'
    * def itemTitle919910 = 'DCB Item Title C919910'
    * def itemBarcode919910 = 'C919910bc'
    * def itemId919910 = 'c9199101-0000-4000-a000-000000000001'
    * def loanPolicyId919910 = 'c9199100-0000-4000-a000-000000000001'
    * def nonExistTxnId = '919910notfound'

  @C919910
  Scenario: Create BORROWING-PICKUP DCB transaction and verify block-renewal and unblock-renewal endpoints

    # Precondition: create loan policy - Rolling, 1 week, 3 renewals allowed, renew from current due date
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId919910)",
      "name": "Loan Policy C919910",
      "loanable": true,
      "loansPolicy": {
        "profileId": "Rolling",
        "period": { "duration": 1, "intervalId": "Weeks" },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
      },
      "renewable": true,
      "renewalsPolicy": {
        "unlimited": false,
        "numberAllowed": 3.0,
        "renewFromId": "CURRENT_DUE_DATE",
        "differentPeriod": false
      }
    }
    """
    When method POST
    Then status 201

    # Precondition: add patron-group circulation rule applying the new loan policy
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId919910 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Step 1: Create DCB transaction with role = BORROWING-PICKUP using existing patron (patronId31 / patronBarcode31)
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId919910
    * createReq.item.title = itemTitle919910
    * createReq.item.barcode = itemBarcode919910
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.patron.group = patronGroupName
    * createReq.pickup.servicePointId = servicePointId21
    * createReq.pickup.servicePointName = servicePointName21
    * createReq.role = 'BORROWING-PICKUP'

    * def orgPath = '/transactions/' + txnId
    * def newPath = proxyCall == true ? proxyPath + orgPath : orgPath
    * def orgPathStatus = '/transactions/' + txnId + '/status'
    * def newPathStatus = proxyCall == true ? proxyPath + orgPathStatus : orgPathStatus
    * def orgPathBlock = '/transactions/' + txnId + '/block-renewal'
    * def newPathBlock = proxyCall == true ? proxyPath + orgPathBlock : orgPathBlock
    * def orgPathUnblock = '/transactions/' + txnId + '/unblock-renewal'
    * def newPathUnblock = proxyCall == true ? proxyPath + orgPathUnblock : orgPathUnblock

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcode919910
    And match $.patron.id == patronId31

    # Step 2: Transition status to OPEN
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    # Step 3: Check in the item - item moves to "Awaiting pickup"
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcode919910

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcode919910 + ')'
    And retry until response.items[0].status.name == 'Awaiting pickup'
    When method GET
    Then status 200

    # Step 4: Check out the item to patron
    * def checkOutByBarcodeId = call uuid1
    * def checkOutRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutRequest.itemBarcode = itemBarcode919910
    * checkOutRequest.userBarcode = patronBarcode31
    * checkOutRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcode919910 + ')'
    And retry until response.items[0].status.name == 'Checked out'
    When method GET
    Then status 200

    # Step 5: Verify transaction status shows renewalCount=0, renewalMaxCount=3
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'ITEM_CHECKED_OUT' && response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 0 && response.item.renewalInfo.renewalMaxCount == 3 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 6: Renew the loan - renewal count increases to 1
    * url baseUrl
    * def renewReq = { itemBarcode: '#(itemBarcode919910)', userBarcode: '#(patronBarcode31)' }
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 1

    # Step 7: Verify transaction status shows renewalCount=1
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 1 && response.item.renewalInfo.renewalMaxCount == 3 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 8: Block renewal for the transaction - response code 204
    Given path newPathBlock
    And param apikey = key
    When method PUT
    Then status 204

    # Step 9: Verify transaction status shows renewalCount=2147483647 (Integer.MAX_VALUE), renewalMaxCount unchanged
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 2147483647 && response.item.renewalInfo.renewalMaxCount == 3
    When method GET
    Then status 200

    # Step 10: Attempt renewal - expect failure because renewalCount is now MAX_VALUE
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 422

    # Step 11: Block renewal again - idempotent, expect 204 with no error
    * url baseUrlNew
    Given path newPathBlock
    And param apikey = key
    When method PUT
    Then status 204

    # Steps 12-13: Verify transaction status still shows renewalCount=2147483647
    Given path newPathStatus
    And param apikey = key
    When method GET
    Then status 200
    And match $.item.renewalInfo.renewalCount == 2147483647
    And match $.item.renewalInfo.renewalMaxCount == 3

    # Step 14: Override renewal - succeeds despite block; DCB renewalCount mirrors the FOLIO loan
    # After block sets loan renewalCount=Integer.MAX_VALUE, override increments it causing overflow:
    # 2147483647 + 1 = -2147483648 (Integer.MIN_VALUE). DCB status reflects this value.
    * url baseUrl
    * def overrideRenewReq = { itemBarcode: '#(itemBarcode919910)', userBarcode: '#(patronBarcode31)', servicePointId: '#(servicePointId)', overrideBlocks: { renewalBlock: {}, comment: 'Override renewal for C919910' } }
    Given path 'circulation', 'renew-by-barcode'
    And request overrideRenewReq
    When method POST
    Then status 200

    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    When method GET
    Then status 200
    And match $.item.renewalInfo.renewalCount == -2147483648
    And match $.item.renewalInfo.renewalMaxCount == 3

    # Step 15: Unblock renewal for the transaction - response code 204
    Given path newPathUnblock
    And param apikey = key
    When method PUT
    Then status 204

    # Step 16: Verify transaction status shows renewalCount=0 (reset after unblock)
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 0 && response.item.renewalInfo.renewalMaxCount == 3 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 17: Renew the loan - renewal succeeds after unblock, DCB renewalCount increases to 1
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 1

    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 1 && response.item.renewalInfo.renewalMaxCount == 3 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 18: Unblock renewal again - idempotent, expect 204 with no error
    Given path newPathUnblock
    And param apikey = key
    When method PUT
    Then status 204

    # Step 19: Verify transaction status shows renewalCount=0 (reset again after second unblock)
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 0 && response.item.renewalInfo.renewalMaxCount == 3 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 20: Block renewal with non-existing transaction ID - expect 404 Not Found
    * def orgPathBlockNonExist = '/transactions/' + nonExistTxnId + '/block-renewal'
    * def newPathBlockNonExist = proxyCall == true ? proxyPath + orgPathBlockNonExist : orgPathBlockNonExist
    Given path newPathBlockNonExist
    And param apikey = key
    When method PUT
    Then status 404
    And match $.errors[0].message contains 'DCB Transaction was not found by id='

    # Step 21: Unblock renewal with non-existing transaction ID - expect 404 Not Found
    * def orgPathUnblockNonExist = '/transactions/' + nonExistTxnId + '/unblock-renewal'
    * def newPathUnblockNonExist = proxyCall == true ? proxyPath + orgPathUnblockNonExist : orgPathUnblockNonExist
    Given path newPathUnblockNonExist
    And param apikey = key
    When method PUT
    Then status 404
    And match $.errors[0].message contains 'DCB Transaction was not found by id='
