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

    # Items — each starts in Available; will be transitioned to the required status via valid FOLIO flows
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

    # Local FOLIO requester/borrower — a real user needed for creating circulation requests
    * def localUserId630 = 'f6304930-4f30-4901-8abc-000000000030'
    * def localUserBarcode630 = 'FAT-630490-U30'

    # DCB patron IDs — non-existing users; DCB will create shadow patrons for these
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

    # Static ID for the checkout request body (must be unique per tenant run; ephemeral tenants prevent collisions)
    * def checkOutByBarcodeId630 = 'f6304920-4f30-4901-8abc-000000000020'

    # Address type for delivery request (must be created at runtime; not pre-seeded in ephemeral tenants)
    * def addressTypeId630 = 'f6304940-4f30-4901-8abc-000000000040'

  @C630490
  Scenario: Create LENDER transactions for items in various statuses and verify full lending flow
    # Create 5 items in Available status
    * def item1 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item1.id = itemId630_1
    * item1.barcode = itemBarcode630_1
    * item1.holdingsRecordId = holdingId
    * item1.materialType.id = intMaterialTypeId
    * item1.status.name = 'Available'
    Given path 'inventory', 'items'
    And request item1
    When method POST
    Then status 201

    * def item2 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item2.id = itemId630_2
    * item2.barcode = itemBarcode630_2
    * item2.holdingsRecordId = holdingId
    * item2.materialType.id = intMaterialTypeId
    * item2.status.name = 'Available'
    Given path 'inventory', 'items'
    And request item2
    When method POST
    Then status 201

    * def item3 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item3.id = itemId630_3
    * item3.barcode = itemBarcode630_3
    * item3.holdingsRecordId = holdingId
    * item3.materialType.id = intMaterialTypeId
    * item3.status.name = 'Available'
    Given path 'inventory', 'items'
    And request item3
    When method POST
    Then status 201

    * def item4 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item4.id = itemId630_4
    * item4.barcode = itemBarcode630_4
    * item4.holdingsRecordId = holdingId
    * item4.materialType.id = intMaterialTypeId
    * item4.status.name = 'Available'
    Given path 'inventory', 'items'
    And request item4
    When method POST
    Then status 201

    * def item5 = read('classpath:volaris/mod-dcb/features/samples/item/item-entity-request.json')
    * item5.id = itemId630_5
    * item5.barcode = itemBarcode630_5
    * item5.holdingsRecordId = holdingId
    * item5.materialType.id = intMaterialTypeId
    * item5.status.name = 'Available'
    Given path 'inventory', 'items'
    And request item5
    When method POST
    Then status 201

    # Create address type at runtime (not pre-seeded in ephemeral tenants)
    Given path 'addresstypes'
    And request { id: '#(addressTypeId630)', addressType: 'DCB Home', desc: 'Address type for DCB delivery test' }
    When method POST
    Then status 201

    # Create a local FOLIO user needed for checkout and circulation requests
    * def localUser630 = read('classpath:volaris/mod-dcb/features/samples/user/user-entity-request.json')
    * localUser630.id = localUserId630
    * localUser630.barcode = localUserBarcode630
    * localUser630.patronGroup = patronGroupId
    * localUser630.personal.addresses = [{ addressLine1: '123 Main St', addressTypeId: addressTypeId630, primaryAddress: true }]
    Given path 'users'
    And request localUser630
    When method POST
    Then status 201

    # Precondition #1: item in "Checked out" status — check out item1
    * def intLoanDate = '2021-10-27T13:25:46.000Z'
    * def checkOutReq1 = read('classpath:volaris/mod-dcb/features/samples/check-out/check-out-by-barcode-entity-request.json')
    * checkOutReq1.id = checkOutByBarcodeId630
    * checkOutReq1.itemBarcode = itemBarcode630_1
    * checkOutReq1.userBarcode = localUserBarcode630
    * checkOutReq1.servicePointId = servicePointId
    * checkOutReq1.loanDate = intLoanDate
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutReq1
    When method POST
    Then status 201

    Given path 'inventory', 'items', itemId630_1
    When method GET
    Then status 200
    And match $.status.name == 'Checked out'

    # Precondition #2: item in "Paged" status — create a Page request for item2
    # Use servicePointId21 as pickup SP so DCB's own request (pickup = servicePointId)
    # can be distinguished; this request will be cancelled in step 6.
    Given path 'circulation', 'requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Item",
        "requestDate": "2021-10-27T15:51:02Z",
        "itemId": "#(itemId630_2)",
        "holdingsRecordId": "#(holdingId)",
        "instanceId": "#(instanceId)",
        "requesterId": "#(localUserId630)",
        "pickupServicePointId": "#(servicePointId21)"
      }
      """
    When method POST
    Then status 201
    * def preconReqId2 = $.id

    Given path 'inventory', 'items', itemId630_2
    When method GET
    Then status 200
    And match $.status.name == 'Paged'

    # Precondition #3: item in "In transit" status — check in at non-home SP
    * def intCheckInDate = call read('classpath:volaris/mod-dcb/features/util/get-time-now-function.js')
    * def checkInReq3 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInReq3.servicePointId = servicePointId11
    * checkInReq3.itemBarcode = itemBarcode630_3
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInReq3
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'

    # Precondition #4: item in "Awaiting pickup" status
    # Create a Page request for item4 (Hold Shelf)
    Given path 'circulation', 'requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Hold Shelf",
        "requestLevel": "Item",
        "requestDate": "2021-10-27T15:51:02Z",
        "itemId": "#(itemId630_4)",
        "holdingsRecordId": "#(holdingId)",
        "instanceId": "#(instanceId)",
        "requesterId": "#(localUserId630)",
        "pickupServicePointId": "#(servicePointId11)"
      }
      """
    When method POST
    Then status 201
    * def preconReqId4 = $.id

    # Check in at the pickup service point so item becomes Awaiting pickup
    * def checkInReq4pre = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInReq4pre.servicePointId = servicePointId11
    * checkInReq4pre.itemBarcode = itemBarcode630_4
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInReq4pre
    When method POST
    Then status 200
    And match $.item.status.name == 'Awaiting pickup'

    # Precondition #5: item in "Awaiting delivery" status
    # Create a Page delivery request for item5
    Given path 'circulation', 'requests'
    And request
      """
      {
        "requestType": "Page",
        "fulfillmentPreference": "Delivery",
        "requestLevel": "Item",
        "requestDate": "2021-10-27T15:51:02Z",
        "itemId": "#(itemId630_5)",
        "holdingsRecordId": "#(holdingId)",
        "instanceId": "#(instanceId)",
        "requesterId": "#(localUserId630)",
        "deliveryAddressTypeId": "#(addressTypeId630)",
        "pickupServicePointId": "#(servicePointId)"
      }
      """
    When method POST
    Then status 201
    * def preconReqId5 = $.id

    # Check in at the home service point so item becomes Awaiting delivery
    * def checkInReq5pre = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkInReq5pre.servicePointId = servicePointId
    * checkInReq5pre.itemBarcode = itemBarcode630_5
    Given path 'circulation', 'check-in-by-barcode'
    And request checkInReq5pre
    When method POST
    Then status 200
    And match $.item.status.name == 'Awaiting delivery'

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
    # Item2 is already Paged (due to preconReqId2). DCB creates the transaction
    # and queues its own Page request behind the existing one.
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

    Given path 'inventory', 'items', itemId630_2
    When method GET
    Then status 200
    And match $.status.name == 'Paged'

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

    # Step 6: Finish all outstanding requests/loans and drive each transaction
    # to CLOSED.  For items with an open pre-condition request (Paged/Awaiting
    # pickup/Awaiting delivery) we cancel that request first, then check in so
    # the item goes In transit toward the DCB service point.

    # Transaction 1 flow (item was "Checked out")
    # Return the item from the patron so the DCB check-in can move it In transit
    * def checkIn1 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn1.servicePointId = servicePointId11
    * checkIn1.itemBarcode = itemBarcode630_1
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn1
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * call read('classpath:volaris/mod-dcb/reusable/complete-lender-transaction.feature') { txnId: '#(txnId630_1)', itemBarcode: '#(itemBarcode630_1)', checkInServicePointId: '#(servicePointId11)' }

    # Transaction 2 flow (item was "Paged")
    # Cancel the pre-condition Page request (by localUser630) so DCB's own request
    # becomes the active one, then check in to send the item In transit.
    * def cancelReq2 = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelReq2.cancellationReasonId = cancellationReasonId
    * cancelReq2.cancelledByUserId = localUserId630
    * cancelReq2.requesterId = localUserId630
    * cancelReq2.requestLevel = 'Item'
    * cancelReq2.holdingsRecordId = holdingId
    * cancelReq2.requestType = 'Page'
    * cancelReq2.itemId = itemId630_2
    * cancelReq2.pickupServicePointId = servicePointId21
    Given path 'circulation', 'requests', preconReqId2
    And request cancelReq2
    When method PUT
    Then status 204
    * call pause 2000

    * def checkIn2 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn2.servicePointId = servicePointId11
    * checkIn2.itemBarcode = itemBarcode630_2
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn2
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * call read('classpath:volaris/mod-dcb/reusable/complete-lender-transaction.feature') { txnId: '#(txnId630_2)', itemBarcode: '#(itemBarcode630_2)', checkInServicePointId: '#(servicePointId11)' }

    # Transaction 3 flow (item was "In transit")
    # Item is In transit to its home SP.  Checking in at the home SP resolves that
    # in-transit; because DCB's Hold request is now active (pickup SP ≠ home SP),
    # FOLIO immediately routes the item In transit to the DCB pickup SP, which
    # is what triggers CREATED → OPEN.
    * def checkIn3a = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn3a.servicePointId = servicePointId
    * checkIn3a.itemBarcode = itemBarcode630_3
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn3a
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * call read('classpath:volaris/mod-dcb/reusable/complete-lender-transaction.feature') { txnId: '#(txnId630_3)', itemBarcode: '#(itemBarcode630_3)', checkInServicePointId: '#(servicePointId11)' }

    # Transaction 4 flow (item was "Awaiting pickup")
    # Cancel the pre-condition request so the item is freed, then check in at sp11.
    * def cancelReq4 = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelReq4.cancellationReasonId = cancellationReasonId
    * cancelReq4.cancelledByUserId = localUserId630
    * cancelReq4.requesterId = localUserId630
    * cancelReq4.requestLevel = 'Item'
    * cancelReq4.holdingsRecordId = holdingId
    * cancelReq4.requestType = 'Page'
    * cancelReq4.itemId = itemId630_4
    * cancelReq4.pickupServicePointId = servicePointId11
    Given path 'circulation', 'requests', preconReqId4
    And request cancelReq4
    When method PUT
    Then status 204
    * call pause 5000

    * def checkIn4 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn4.servicePointId = servicePointId11
    * checkIn4.itemBarcode = itemBarcode630_4
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn4
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * call read('classpath:volaris/mod-dcb/reusable/complete-lender-transaction.feature') { txnId: '#(txnId630_4)', itemBarcode: '#(itemBarcode630_4)', checkInServicePointId: '#(servicePointId11)' }

    # Transaction 5 flow (item was "Awaiting delivery")
    # Cancel the pre-condition delivery request, then check in at sp11.
    * def cancelReq5 = read('classpath:volaris/mod-dcb/features/samples/request/cancel-request-entity-request.json')
    * cancelReq5.cancellationReasonId = cancellationReasonId
    * cancelReq5.cancelledByUserId = localUserId630
    * cancelReq5.requesterId = localUserId630
    * cancelReq5.requestLevel = 'Item'
    * cancelReq5.holdingsRecordId = holdingId
    * cancelReq5.requestType = 'Page'
    * cancelReq5.itemId = itemId630_5
    * cancelReq5.pickupServicePointId = servicePointId
    Given path 'circulation', 'requests', preconReqId5
    And request cancelReq5
    When method PUT
    Then status 204
    * call pause 5000

    * def checkIn5 = read('classpath:volaris/mod-dcb/features/samples/check-in/check-in-by-barcode-entity-request.json')
    * checkIn5.servicePointId = servicePointId11
    * checkIn5.itemBarcode = itemBarcode630_5
    Given path 'circulation', 'check-in-by-barcode'
    And request checkIn5
    When method POST
    Then status 200
    And match $.item.status.name == 'In transit'
    * call pause 5000

    * call read('classpath:volaris/mod-dcb/reusable/complete-lender-transaction.feature') { txnId: '#(txnId630_5)', itemBarcode: '#(itemBarcode630_5)', checkInServicePointId: '#(servicePointId11)' }
