Feature: Non-Lender Role Renew Restriction

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
    * def txnIdBr = '6563111'
    * def txnIdBp = '6563112'
    * def txnIdP = '6563113'
    * def loanPolicyId656311 = 'c6563110-0004-4000-a000-000000000001'
    * def patronGroup2Id656311 = 'c6563110-0002-4000-a000-000000000001'
    * def patronGroup2Name656311 = 'dcb-grp-c656311'
    * def patron2Id656311 = 'c6563110-0001-4000-a000-000000000001'
    * def patron2Barcode656311 = 'FAT-656311-P2'
    * def materialType2Id656311 = 'c6563110-0003-4000-a000-000000000001'
    * def materialType2Name656311 = 'FAT-mat-c656311'
    * def itemIdBr656311 = 'c6563111-0000-4000-a000-000000000001'
    * def itemBarcodeBr656311 = 'C656311BRbc'
    * def itemIdBp656311 = 'c6563112-0000-4000-a000-000000000001'
    * def itemBarcodeBp656311 = 'C656311BPbc'
    * def itemIdP656311 = 'c6563113-0000-4000-a000-000000000001'
    * def itemBarcodeP656311 = 'C656311Pbc'
    * def pickupSpNameBr = 'sp-c656311-br'
    * def pickupLibCodeBr = 'lib656311br'

  @C656311
  Scenario: Verify renew returns 400 for BORROWER, BORROWING-PICKUP, and PICKUP roles

    # Precondition: create loan policy - Rolling, 1 hour, renewable
    Given path 'loan-policy-storage', 'loan-policies'
    And request
    """
    {
      "id": "#(loanPolicyId656311)",
      "name": "Loan Policy C656311",
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

    # Precondition: create patron group 2 for BORROWING-PICKUP patron
    Given path 'groups'
    And request { id: '#(patronGroup2Id656311)', group: '#(patronGroup2Name656311)' }
    When method POST
    Then status 201

    # Precondition: create patron for BORROWING-PICKUP role (patron group 2)
    Given path 'users'
    And request
    """
    {
      "id": "#(patron2Id656311)",
      "active": true,
      "departments": [],
      "patronGroup": "#(patronGroup2Id656311)",
      "barcode": "#(patron2Barcode656311)",
      "personal": {
        "email": "testuser@gmail.com",
        "firstName": "first name",
        "lastName": "last name",
        "preferredContactTypeId": "002"
      }
    }
    """
    When method POST
    Then status 201

    # Precondition: create new material type for PICKUP item
    Given path 'material-types'
    And request { id: '#(materialType2Id656311)', name: '#(materialType2Name656311)' }
    When method POST
    Then status 201

    # Precondition: create circulation rules applying loan policy to patron group 1, patron group 2, and new material type
    * def rulesText = 'priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\nm ' + materialType2Id656311 + ': l ' + loanPolicyId656311 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroupId + ': l ' + loanPolicyId656311 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709\ng ' + patronGroup2Id656311 + ': l ' + loanPolicyId656311 + ' r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'
    * def circRulesReq = { id: '1721f01b-e69d-5c4c-5df2-523428a04c55', rulesAsText: '#(rulesText)' }
    Given path 'circulation', 'rules'
    And request circRulesReq
    When method PUT
    Then status 204

    # Switch to DCB URL and define all path variables
    * def baseUrlNew = proxyCall == true ? edgeUrl : baseUrl
    * url baseUrlNew

    * def orgPathBr = '/transactions/' + txnIdBr
    * def newPathBr = proxyCall == true ? proxyPath + orgPathBr : orgPathBr
    * def orgPathStatusBr = '/transactions/' + txnIdBr + '/status'
    * def newPathStatusBr = proxyCall == true ? proxyPath + orgPathStatusBr : orgPathStatusBr
    * def orgPathRenewBr = '/transactions/' + txnIdBr + '/renew'
    * def newPathRenewBr = proxyCall == true ? proxyPath + orgPathRenewBr : orgPathRenewBr

    * def orgPathBp = '/transactions/' + txnIdBp
    * def newPathBp = proxyCall == true ? proxyPath + orgPathBp : orgPathBp
    * def orgPathStatusBp = '/transactions/' + txnIdBp + '/status'
    * def newPathStatusBp = proxyCall == true ? proxyPath + orgPathStatusBp : orgPathStatusBp
    * def orgPathRenewBp = '/transactions/' + txnIdBp + '/renew'
    * def newPathRenewBp = proxyCall == true ? proxyPath + orgPathRenewBp : orgPathRenewBp

    * def orgPathP = '/transactions/' + txnIdP
    * def newPathP = proxyCall == true ? proxyPath + orgPathP : orgPathP
    * def orgPathStatusP = '/transactions/' + txnIdP + '/status'
    * def newPathStatusP = proxyCall == true ? proxyPath + orgPathStatusP : orgPathStatusP
    * def orgPathRenewP = '/transactions/' + txnIdP + '/renew'
    * def newPathRenewP = proxyCall == true ? proxyPath + orgPathRenewP : orgPathRenewP

    # Load status update request bodies
    * def updateToOpenRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-open.json')
    * def updateToAwaitingPickupRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def updateToCheckedOutRequest = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')

    # Setup: Create BORROWER transaction using real patron (patronId31, patron group 1)
    * def createReqBr = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReqBr.item.id = itemIdBr656311
    * createReqBr.item.barcode = itemBarcodeBr656311
    * createReqBr.item.materialType = materialTypeName
    * createReqBr.patron.id = patronId31
    * createReqBr.patron.barcode = patronBarcode31
    * createReqBr.patron.group = patronGroupName
    * createReqBr.pickup.servicePointName = pickupSpNameBr
    * createReqBr.pickup.libraryCode = pickupLibCodeBr
    * createReqBr.role = 'BORROWER'

    Given path newPathBr
    And param apikey = key
    And request createReqBr
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcodeBr656311
    And match $.patron.id == patronId31

    # Advance BORROWER transaction to ITEM_CHECKED_OUT
    Given path newPathStatusBr
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    Given path newPathStatusBr
    And param apikey = key
    And request updateToAwaitingPickupRequest
    When method PUT
    Then status 200

    Given path newPathStatusBr
    And param apikey = key
    And request updateToCheckedOutRequest
    When method PUT
    Then status 200

    # Setup: Create BORROWING-PICKUP transaction using real patron (patron2Id656311, patron group 2)
    * def createReqBp = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReqBp.item.id = itemIdBp656311
    * createReqBp.item.barcode = itemBarcodeBp656311
    * createReqBp.item.materialType = materialTypeName
    * createReqBp.patron.id = patron2Id656311
    * createReqBp.patron.barcode = patron2Barcode656311
    * createReqBp.patron.group = patronGroup2Name656311
    * createReqBp.pickup.servicePointId = servicePointId21
    * createReqBp.pickup.servicePointName = servicePointName21
    * createReqBp.role = 'BORROWING-PICKUP'

    Given path newPathBp
    And param apikey = key
    And request createReqBp
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcodeBp656311
    And match $.patron.id == patron2Id656311

    # Advance BORROWING-PICKUP transaction to OPEN
    Given path newPathStatusBp
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    # Advance BORROWING-PICKUP to AWAITING_PICKUP and ITEM_CHECKED_OUT via circulation check-in/check-out
    # (PUT /status -> AWAITING_PICKUP is not implemented for BORROWING-PICKUP role)
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcodeBp656311
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcodeBp656311 + ')'
    And retry until response.items[0].status.name == 'Awaiting pickup'
    When method GET
    Then status 200

    * def checkOutByBarcodeId = call uuid1
    * def checkOutRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutRequest.itemBarcode = itemBarcodeBp656311
    * checkOutRequest.userBarcode = patron2Barcode656311
    * checkOutRequest.servicePointId = servicePointId21
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

    * url baseUrlNew

    # Setup: Create PICKUP transaction using shadow patron with new material type
    * def createReqP = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * createReqP.item.id = itemIdP656311
    * createReqP.item.barcode = itemBarcodeP656311
    * createReqP.item.materialType = materialType2Name656311
    * createReqP.patron.id = patronId3
    * createReqP.patron.barcode = patronBarcode3
    * createReqP.patron.group = patronGroupName
    * createReqP.pickup.servicePointId = servicePointId21
    * createReqP.pickup.servicePointName = servicePointName21
    * createReqP.role = 'PICKUP'

    Given path newPathP
    And param apikey = key
    And request createReqP
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.barcode == itemBarcodeP656311
    And match $.patron.id == patronId3

    # Advance PICKUP transaction to OPEN
    Given path newPathStatusP
    And param apikey = key
    And request updateToOpenRequest
    When method PUT
    Then status 200

    # Advance PICKUP to AWAITING_PICKUP and ITEM_CHECKED_OUT via circulation check-in/check-out
    # (PUT /status -> AWAITING_PICKUP is not implemented for PICKUP role)
    * url baseUrl
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInRequest = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInRequest.servicePointId = servicePointId21
    * checkInRequest.itemBarcode = itemBarcodeP656311
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInRequest
    When method POST
    Then status 200

    Given path 'circulation-item'
    And param query = '(barcode= ' + itemBarcodeP656311 + ')'
    And retry until response.items[0].status.name == 'Awaiting pickup'
    When method GET
    Then status 200

    * def checkOutByBarcodeId = call uuid1
    * def checkOutRequest = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutRequest.itemBarcode = itemBarcodeP656311
    * checkOutRequest.userBarcode = patronBarcode3
    * checkOutRequest.servicePointId = servicePointId21
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutRequest
    When method POST
    Then status 201

    * url baseUrlNew

    # Step 1: Try to renew BORROWER transaction - expect 400 with role error
    Given path newPathRenewBr
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message == "Loan couldn't be renewed with role BORROWER, it could be renewed only with role LENDER"

    # Step 2: Try to renew BORROWING-PICKUP transaction - expect 400 with role error
    Given path newPathRenewBp
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message == "Loan couldn't be renewed with role BORROWING-PICKUP, it could be renewed only with role LENDER"

    # Step 3: Try to renew PICKUP transaction - expect 400 with role error
    Given path newPathRenewP
    And param apikey = key
    When method PUT
    Then status 400
    And match $.errors[0].message == "Loan couldn't be renewed with role PICKUP, it could be renewed only with role LENDER"
