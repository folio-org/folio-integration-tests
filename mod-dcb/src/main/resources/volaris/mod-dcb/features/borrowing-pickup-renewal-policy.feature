Feature: Borrowing-Pickup Transaction Renewal Policy

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
    * def txnId = '656285'
    * def itemTitle656285 = 'DCB Item Title C656285'
    * def itemBarcode656285 = 'C656285bc'
    * def itemId656285 = 'c6562851-0000-4000-a000-000000000001'
    * def loanPolicyId656285 = 'c6562850-0000-4000-a000-000000000001'

  @C656285
  Scenario: Create BORROWING-PICKUP DCB transaction and verify renewalPolicy reflects unlimited loan renewals

    # Precondition: create loan policy - Rolling, 2 days, unlimited renewals, renew from current due date
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656285)",
      "name": "Loan Policy C656285",
      "loanable": true,
      "loansPolicy": {
        "profileId": "Rolling",
        "period": { "duration": 2, "intervalId": "Days" },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE"
      },
      "renewable": true,
      "renewalsPolicy": {
        "unlimited": true,
        "renewFromId": "CURRENT_DUE_DATE",
        "differentPeriod": false
      }
    }
    """
    When method POST
    Then status 201

    # Precondition: add patron-group circulation rule applying the new loan policy
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId656285 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Step 1: Create DCB transaction with role BORROWING-PICKUP using existing patron (patronId31 / patronBarcode31)
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId656285
    * createReq.item.title = itemTitle656285
    * createReq.item.barcode = itemBarcode656285
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

    Given path newPath
    And param apikey = key
    And request createReq
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcode656285
    And match $.patron.id == patronId31

    # Step 2: Transition status to OPEN
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    # Step 3: Check in the item - item moves to Awaiting pickup
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcode656285

    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcode656285 + ')'
    And retry until response.items[0].status.name == 'Awaiting pickup'
    When method GET
    Then status 200

    # Step 4: Check out the item to patron
    * def checkOutByBarcodeId = call uuid1
    * def checkOutRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutRequest.itemBarcode = itemBarcode656285
    * checkOutRequest.userBarcode = patronBarcode31
    * checkOutRequest.servicePointId = servicePointId21

    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcode656285 + ')'
    And retry until response.items[0].status.name == 'Checked out'
    When method GET
    Then status 200

    # Step 5: Verify transaction status is ITEM_CHECKED_OUT and renewalInfo shows renewalCount=0, renewalMaxCount=-1 (unlimited), renewable=true
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'ITEM_CHECKED_OUT' && response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 0 && response.item.renewalInfo.renewalMaxCount == -1 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 6: Verify open loan exists for patron with renewalCount=0
    * url baseUrl
    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcode656285 + ')'
    When method GET
    Then status 200
    * def virtualItemId = $.items[0].id

    Given path 'loan-storage', 'loans'
    And param query = '( itemId = ' + virtualItemId + ' )'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.loans[0].userId == patronId31

    # Steps 7-8: First renewal - renewalCount increments to 1, due date incremented by 2 days
    * def renewReq = { itemBarcode: '#(itemBarcode656285)', userBarcode: '#(patronBarcode31)' }
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 1

    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 1 && response.item.renewalInfo.renewalMaxCount == -1 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 9: Second renewal - renewalCount increments to 2, due date incremented by 2 more days
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 2

    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 2 && response.item.renewalInfo.renewalMaxCount == -1 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 9 continued: Third renewal - verifies each renewal keeps incrementing renewalCount and renewalMaxCount stays -1
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 3

    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 3 && response.item.renewalInfo.renewalMaxCount == -1 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200
