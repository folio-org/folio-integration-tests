Feature: Lending transactions for items in various statuses

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
    * configure retry = { count: 5, interval: 1000 }

    * def itemId630_1 = 'f6304901-4f30-4901-8abc-000000000001'
    * def itemBarcode630_1 = 'FAT-630490-I01'
    * def itemId630_2 = 'f6304902-4f30-4901-8abc-000000000002'
    * def itemBarcode630_2 = 'FAT-630490-I02'
    * def itemId630_3 = 'f6304903-4f30-4901-8abc-000000000003'
    * def itemBarcode630_3 = 'FAT-630490-I03'
    * def itemId630_4 = 'f6304904-4f30-4901-8abc-000000000004'
    * def itemBarcode630_4 = 'FAT-630490-I04'
    * def itemId630_5 = 'f6304905-4f30-4901-8abc-000000000005'
    * def itemBarcode630_5 = 'FAT-630490-I05'

    * def patronId630_1 = 'f6304911-4f30-4901-8abc-000000000001'
    * def patronBarcode630_1 = 'FAT-630490-P01'
    * def patronId630_2 = 'f6304912-4f30-4901-8abc-000000000002'
    * def patronBarcode630_2 = 'FAT-630490-P02'
    * def patronId630_3 = 'f6304913-4f30-4901-8abc-000000000003'
    * def patronBarcode630_3 = 'FAT-630490-P03'
    * def patronId630_4 = 'f6304914-4f30-4901-8abc-000000000004'
    * def patronBarcode630_4 = 'FAT-630490-P04'
    * def patronId630_5 = 'f6304915-4f30-4901-8abc-000000000005'
    * def patronBarcode630_5 = 'FAT-630490-P05'

    * def txnId630_1 = '630490-01'
    * def txnId630_2 = '630490-02'
    * def txnId630_3 = '630490-03'
    * def txnId630_4 = '630490-04'
    * def txnId630_5 = '630490-05'

  @C630490
  Scenario: Create LENDER transactions for items in various statuses and verify full lending flow
    # Precondition #1: item in "Checked out" status (check out an item in Available status)
    * def item1 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item1.id = itemId630_1
    * item1.barcode = itemBarcode630_1
    * item1.materialType.id = intMaterialTypeId
    * item1.status.name = 'Checked out'
    Given path 'inventory', 'items'
    And request item1
    When method POST
    Then status 201

    # Precondition #2: item in "Paged" status (create a Page request for an Available item)
    * def item2 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item2.id = itemId630_2
    * item2.barcode = itemBarcode630_2
    * item2.materialType.id = intMaterialTypeId
    * item2.status.name = 'Paged'
    Given path 'inventory', 'items'
    And request item2
    When method POST
    Then status 201

    # Precondition #3: item in "In transit" status (check in an Available item at a non-home service point)
    * def item3 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item3.id = itemId630_3
    * item3.barcode = itemBarcode630_3
    * item3.materialType.id = intMaterialTypeId
    * item3.status.name = 'In transit'
    Given path 'inventory', 'items'
    And request item3
    When method POST
    Then status 201

    # Precondition #4: item in "Awaiting pickup" status (Page request + check in at pickup service point)
    * def item4 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item4.id = itemId630_4
    * item4.barcode = itemBarcode630_4
    * item4.materialType.id = intMaterialTypeId
    * item4.status.name = 'Awaiting pickup'
    Given path 'inventory', 'items'
    And request item4
    When method POST
    Then status 201

    # Precondition #5: item in "Awaiting delivery" status (Page delivery request + check in at home service point)
    * def item5 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item5.id = itemId630_5
    * item5.barcode = itemBarcode630_5
    * item5.materialType.id = intMaterialTypeId
    * item5.status.name = 'Awaiting delivery'
    Given path 'inventory', 'items'
    And request item5
    When method POST
    Then status 201

    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def updateToAwaitingPickup = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-awaiting-pickup.json')
    * def updateToItemCheckOut = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-out.json')
    * def updateToItemCheckIn = read('classpath:volaris/mod-dcb/features/samples/transaction/update-dcb-transaction-to-item-check-in.json')

    # Step 1: Create DCB LENDER transaction for "Checked out" item
    * def txnReq1 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * txnReq1.item.id = itemId630_1
    * txnReq1.item.barcode = itemBarcode630_1
    * txnReq1.patron.id = patronId630_1
    * txnReq1.patron.barcode = patronBarcode630_1
    * txnReq1.patron.group = patronGroupName
    * txnReq1.pickup.servicePointName = 'lend_sp_6301'
    * txnReq1.pickup.libraryCode = 'lib6301'
    * txnReq1.role = 'LENDER'
    Given path 'transactions', txnId630_1
    And request txnReq1
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId630_1
    And match $.patron.id == patronId630_1

    # Step 2: Create DCB LENDER transaction for "Paged" item
    * def txnReq2 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * txnReq2.item.id = itemId630_2
    * txnReq2.item.barcode = itemBarcode630_2
    * txnReq2.patron.id = patronId630_2
    * txnReq2.patron.barcode = patronBarcode630_2
    * txnReq2.patron.group = patronGroupName
    * txnReq2.pickup.servicePointName = 'lend_sp_6302'
    * txnReq2.pickup.libraryCode = 'lib6302'
    * txnReq2.role = 'LENDER'
    Given path 'transactions', txnId630_2
    And request txnReq2
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId630_2
    And match $.patron.id == patronId630_2

    # Step 3: Create DCB LENDER transaction for "In transit" item
    * def txnReq3 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * txnReq3.item.id = itemId630_3
    * txnReq3.item.barcode = itemBarcode630_3
    * txnReq3.patron.id = patronId630_3
    * txnReq3.patron.barcode = patronBarcode630_3
    * txnReq3.patron.group = patronGroupName
    * txnReq3.pickup.servicePointName = 'lend_sp_6303'
    * txnReq3.pickup.libraryCode = 'lib6303'
    * txnReq3.role = 'LENDER'
    Given path 'transactions', txnId630_3
    And request txnReq3
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId630_3
    And match $.patron.id == patronId630_3

    # Step 4: Create DCB LENDER transaction for "Awaiting pickup" item
    * def txnReq4 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * txnReq4.item.id = itemId630_4
    * txnReq4.item.barcode = itemBarcode630_4
    * txnReq4.patron.id = patronId630_4
    * txnReq4.patron.barcode = patronBarcode630_4
    * txnReq4.patron.group = patronGroupName
    * txnReq4.pickup.servicePointName = 'lend_sp_6304'
    * txnReq4.pickup.libraryCode = 'lib6304'
    * txnReq4.role = 'LENDER'
    Given path 'transactions', txnId630_4
    And request txnReq4
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId630_4
    And match $.patron.id == patronId630_4

    # Step 5: Create DCB LENDER transaction for "Awaiting delivery" item
    * def txnReq5 = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * txnReq5.item.id = itemId630_5
    * txnReq5.item.barcode = itemBarcode630_5
    * txnReq5.patron.id = patronId630_5
    * txnReq5.patron.barcode = patronBarcode630_5
    * txnReq5.patron.group = patronGroupName
    * txnReq5.pickup.servicePointName = 'lend_sp_6305'
    * txnReq5.pickup.libraryCode = 'lib6305'
    * txnReq5.role = 'LENDER'
    Given path 'transactions', txnId630_5
    And request txnReq5
    When method POST
    Then status 201
    And match $.status == 'CREATED'
    And match $.item.id == itemId630_5
    And match $.patron.id == patronId630_5

    # Step 6: Finish each transaction flow
    # After check-in, items are sent in transit to the DCB service points;
    # each transaction moves through statuses according to flow without errors

    # Transaction 1 flow (item was "Checked out")
    * def checkIn1 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn1.servicePointId = servicePointId11
    * checkIn1.itemBarcode = itemBarcode630_1
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn1
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', txnId630_1, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId630_1, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_1, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId630_1, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def checkIn1b = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn1b.servicePointId = servicePointId11
    * checkIn1b.itemBarcode = itemBarcode630_1
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn1b
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_1, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200

    # Transaction 2 flow (item was "Paged")
    * def checkIn2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn2.servicePointId = servicePointId11
    * checkIn2.itemBarcode = itemBarcode630_2
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn2
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', txnId630_2, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId630_2, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_2, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId630_2, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def checkIn2b = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn2b.servicePointId = servicePointId11
    * checkIn2b.itemBarcode = itemBarcode630_2
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn2b
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_2, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200

    # Transaction 3 flow (item was "In transit")
    * def checkIn3 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn3.servicePointId = servicePointId11
    * checkIn3.itemBarcode = itemBarcode630_3
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn3
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', txnId630_3, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId630_3, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_3, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId630_3, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def checkIn3b = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn3b.servicePointId = servicePointId11
    * checkIn3b.itemBarcode = itemBarcode630_3
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn3b
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_3, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200

    # Transaction 4 flow (item was "Awaiting pickup")
    * def checkIn4 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn4.servicePointId = servicePointId11
    * checkIn4.itemBarcode = itemBarcode630_4
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn4
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', txnId630_4, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId630_4, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_4, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId630_4, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def checkIn4b = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn4b.servicePointId = servicePointId11
    * checkIn4b.itemBarcode = itemBarcode630_4
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn4b
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_4, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200

    # Transaction 5 flow (item was "Awaiting delivery")
    * def checkIn5 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn5.servicePointId = servicePointId11
    * checkIn5.itemBarcode = itemBarcode630_5
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn5
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    Given path 'transactions', txnId630_5, 'status'
    And retry until response.status == 'OPEN'
    When method GET
    Then status 200

    Given path 'transactions', txnId630_5, 'status'
    And request updateToAwaitingPickup
    When method PUT
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_5, 'status'
    And request updateToItemCheckOut
    When method PUT
    Then status 200

    Given path 'transactions', txnId630_5, 'status'
    And request updateToItemCheckIn
    When method PUT
    Then status 200

    * def checkIn5b = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn5b.servicePointId = servicePointId11
    * checkIn5b.itemBarcode = itemBarcode630_5
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn5b
    When method POST
    Then status 200
    * call pause 5000

    Given path 'transactions', txnId630_5, 'status'
    And retry until response.status == 'CLOSED'
    When method GET
    Then status 200
