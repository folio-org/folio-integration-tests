Feature: Borrower Transaction Renewal Policy

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
    * def txnId = '656263'
    * def itemTitle656263 = 'DCB Item Title C656263'
    * def itemBarcode656263 = 'C656263bc'
    * def itemId656263 = 'c6562631-0000-4000-a000-000000000001'
    * def pickupSpName = 'sp-c656263'
    * def pickupLibCode = 'lib656263'
    * def loanPolicyId656263 = 'c6562630-0000-4000-a000-000000000001'

  @C656263
  Scenario: Create BORROWER DCB transaction and verify renewalPolicy reflects loan renewals

    # Precondition: create loan policy - Rolling, 1 hour, 2 renewals allowed, renew from current due date
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656263)",
      "name": "Loan Policy C656263",
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
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId656263 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204 using existing patron (patronId31 / patronBarcode31)
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId656263
    * createReq.item.title = itemTitle656263
    * createReq.item.barcode = itemBarcode656263
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId31
    * createReq.patron.barcode = patronBarcode31
    * createReq.patron.group = patronGroupName
    * createReq.pickup.servicePointName = pickupSpName
    * createReq.pickup.libraryCode = pickupLibCode
    * createReq.role = 'BORROWER'

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
    And match $.item.barcode == itemBarcode656263
    And match $.patron.id == patronId31

    # Step 2: Transition status to OPEN
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    # Step 3: Transition status to AWAITING_PICKUP
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

    # Step 5: Verify renewalInfo present with renewalCount=0, renewalMaxCount=2, renewable=true
    Given path newPathStatus
    And param apikey = key
    And retry until response.status == 'ITEM_CHECKED_OUT' && response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 0 && response.item.renewalInfo.renewalMaxCount == 2 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Steps 6-7: First renewal via circulation API
    * url baseUrl
    * def renewReq = { itemBarcode: '#(itemBarcode656263)', userBarcode: '#(patronBarcode31)' }
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 1

    # Step 8: Verify renewalInfo after first renewal - renewalCount=1
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 1 && response.item.renewalInfo.renewalMaxCount == 2 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Step 9: Second renewal
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 200
    And match $.renewalCount == 2

    # Step 9: Verify renewalInfo after second renewal - renewalCount=2
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 2 && response.item.renewalInfo.renewalMaxCount == 2 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200

    # Steps 10-11: Third renewal attempt - max renewals reached, expected 422
    * url baseUrl
    Given path 'circulation', 'renew-by-barcode'
    And request renewReq
    When method POST
    Then status 422

    # Step 12: Verify renewalInfo unchanged after failed renewal - renewalCount still 2
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    When method GET
    Then status 200
    And match $.item.renewalInfo.renewalCount == 2
    And match $.item.renewalInfo.renewalMaxCount == 2
    And match $.item.renewalInfo.renewable == true

    # Step 13: Override renewal via renew-by-barcode with overrideBlocks
    * url baseUrl
    * def overrideRenewReq = { itemBarcode: '#(itemBarcode656263)', userBarcode: '#(patronBarcode31)', servicePointId: '#(servicePointId)', overrideBlocks: { renewalBlock: {}, comment: 'Override renewal for C656263' } }
    Given path 'circulation', 'renew-by-barcode'
    And request overrideRenewReq
    When method POST
    Then status 200
    And match $.renewalCount == 3

    # Step 14: Verify renewalInfo after override - renewalCount=3, renewalMaxCount=2, renewable=true
    * url baseUrlNew
    Given path newPathStatus
    And param apikey = key
    And retry until response.item != null && response.item.renewalInfo != null && response.item.renewalInfo.renewalCount == 3 && response.item.renewalInfo.renewalMaxCount == 2 && response.item.renewalInfo.renewable == true
    When method GET
    Then status 200
