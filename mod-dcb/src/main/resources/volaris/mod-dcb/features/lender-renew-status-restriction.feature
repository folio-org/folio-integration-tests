Feature: Lender Renew Status Restriction

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
    * def txnId = '656310'
    * def itemId656310 = 'c6563100-0000-4000-a000-000000000001'
    * def itemBarcode656310 = 'C656310bc'
    * def loanPolicyId656310 = 'c6563101-0000-4000-a000-000000000001'
    * def patronId656310 = 'c6563102-0000-4000-a000-000000000001'
    * def patronBarcode656310 = 'FAT-656310-P'
    * def pickupSpName = 'sp-c656310'
    * def pickupLibCode = 'lib656310'

  @C656310
  Scenario: Create LENDER DCB transaction and verify renew is restricted to ITEM_CHECKED_OUT status only

    # Precondition: create item in Available status in Inventory
    * def itemReq = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * itemReq.id = itemId656310
    * itemReq.barcode = itemBarcode656310
    * itemReq.holdingsRecordId = holdingId
    * itemReq.materialType.id = intMaterialTypeId
    * itemReq.status.name = 'Available'
    Given path 'inventory', 'items'
    And request itemReq
    When method POST
    Then status 201

    # Precondition: create loan policy - Rolling, 1 hour, renewable
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656310)",
      "name": "Loan Policy C656310",
      "loanable": true,
      "loansPolicy": {
        "profileId": "Rolling",
        "period": { "duration": 1, "intervalId": "Hours" },
        "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
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

    # Precondition: add material-type circulation rule applying the new loan policy
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm ' + intMaterialTypeId + ': l ' + loanPolicyId656310 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Step 1: Create DCB transaction with role = LENDER
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew
    * def createReq = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReq.item.id = itemId656310
    * createReq.item.barcode = itemBarcode656310
    * createReq.item.materialType = materialTypeName
    * createReq.patron.id = patronId656310
    * createReq.patron.barcode = patronBarcode656310
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
    And match $.item.id == itemId656310
    And match $.patron.id == patronId656310

    # Step 2: Try to renew - transaction in CREATED status, expect 400
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'transaction status CREATED'

    # Step 3: Check in the item at non-home service point - item becomes "In transit", transaction moves to OPEN
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId11
    * checkInRequest.itemBarcode = itemBarcode656310
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'

    # Step 4: Try to renew - transaction in OPEN status, expect 400
    * url baseUrlNew
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'transaction status OPEN'

    # Step 5: Update status to AWAITING_PICKUP
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    # Step 6: Try to renew - transaction in AWAITING_PICKUP status, expect 400
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'transaction status AWAITING_PICKUP'

    # Step 7: Update status to ITEM_CHECKED_OUT
    * def updateToCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToCheckedOutRequest
    When method PUT
    Then status 200

    # Step 8: Update status to ITEM_CHECKED_IN
    * def updateToCheckedInRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')
    Given path newPathStatus
    And param apikey = key
    And request updateToCheckedInRequest
    When method PUT
    Then status 200

    # Step 9: Try to renew - transaction in ITEM_CHECKED_IN status, expect 400
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'transaction status ITEM_CHECKED_IN'

    # Step 10: Check in the item at home service point - item becomes "Available", transaction moves to CLOSED
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest2.servicePointId = servicePointId
    * checkInRequest2.itemBarcode = itemBarcode656310
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest2
    When method POST
    Then status 200
    And match $.item.status.name == 'Available'

    # Step 11: Try to renew - transaction in CLOSED status, expect 400
    * url baseUrlNew
    Given path newPathRenew
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message contains 'transaction status CLOSED'
