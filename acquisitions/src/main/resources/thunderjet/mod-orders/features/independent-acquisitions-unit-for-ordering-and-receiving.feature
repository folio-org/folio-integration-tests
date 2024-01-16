# created for MODORDERS-982
@parallel=false
Feature: Independent acquisitions unit for ordering and receiving

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def orderId3 = callonce uuid5
    * def poLineId1 = callonce uuid6
    * def poLineId2 = callonce uuid7
    * def poLineId3 = callonce uuid8
    * def pieceId1 = callonce uuid9
    * def acqUnitId1 = callonce uuid10
    * def acqUnitId2 = callonce uuid11
    * def acqUnitId3 = callonce uuid12
    * def acqUnitMembershipId1 = callonce uuid13
    * def acqUnitMembershipId2 = callonce uuid14
    * def acqUnitMembershipId3 = callonce uuid15
    * def acqUnitMembershipId4 = callonce uuid16
    * def acqUnitMembershipId5 = callonce uuid17
    * def locationId = callonce uuid18

  ## Acq units inheritance from Order checks
  Scenario: Create Order with acqUnit1, Create PO Line, check that acqUnit1 was inherited from Order to Title
    # 1. Create acq unit
    * configure headers = headersAdmin
    Given path 'acquisitions-units/units'
    And headers headersAdmin
    And request
    """
    {
      "id": '#(acqUnitId1)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "name": "testAcqUnit"
    }
    """
    When method POST
    Then status 201

    # 2. Create acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And request
    """
      {
        "id": '#(acqUnitMembershipId1)',
        "userId": "00000000-1111-5555-9999-999999999992",
        "acquisitionsUnitId": "#(acqUnitId1)"
      }
    """
    When method POST
    Then status 201

    # 3. Create a fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active'}]}
    * configure headers = headersUser

    # 4. Create a composite order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId1)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      "acqUnitIds": ['#(acqUnitId1)']
    }
    """
    When method POST
    Then status 201

    # 5. Create an order line
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId1
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # 6. Open the order
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 6. Check that acqUnit1 was inherited from Order to Title
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200

    And match $.totalRecords == 1

  Scenario: Edit acq units for Order, change should NOT propagated to related Title
    # 1. Edit the composite orde
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.acqUnitIds = []

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 2. Check title has acqUnit
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.titles[0].acqUnitIds[0] == acqUnitId1

  Scenario: Edit acq units for Title, change should NOT propagated to related Order
    # 1. Assign acqUnit to order back
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.acqUnitIds = []

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 2. Remove acqUnit from title
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.acqUnitIds = []
    * def titleId = $.titles[0].id

    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 204

    # 3. Check that order has acqUnitIds
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200
    And match $.orders[0].acqUnitIds == acqUnitId1

  ## Title Acq units protection checks
  Scenario: Assign acqUnit1 to Title and remove acq unit from user membership to check that GET titles API does not return particular title
    # 1. Remove acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId1
    When method DELETE
    Then status 204

    # 2. Retrieve title without acq units membership
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Check that PUT operation is also forbidden when user does not have acqUnit1
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.title = "Updated title"
    * def titleId = $.titles[0].id

    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 409

  Scenario: Assign acqUnit1 to user and check that both GET titles return our title and this title is editable now
    # 1. Assign acq unit membership to user
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And headers headersAdmin
    And request
    """
      {
        "id": '#(acqUnitMembershipId2)',
        "userId": "00000000-1111-5555-9999-999999999992",
        "acquisitionsUnitId": "#(acqUnitId1)"
      }
    """
    When method POST
    Then status 201

    # 2. Retrieve successfully title after re-assign acq unit membership
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.title = "Updated title"
    * def titleId = $.titles[0].id

    # 3. Do PUT operation for title after re-assign acq unit membership
    * configure headers = headersUser
    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 204

  ## Package Order checks
  Scenario: Create package order with acqUnit1 assigned
    # Create a composite order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId3)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      "acqUnitIds": ['#(acqUnitId1)']
    }
    """
    When method POST
    Then status 201

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId3
    * set poLine.purchaseOrderId = orderId3
    * set poLine.isPackage = true
    * set poLine.checkinItems = true
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.fundDistribution[0].fundId = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Create Title for this package order with acqUnit2, check that this POST Title operation is forbidden
    * configure headers = headersUser
    Given path 'orders/titles'
    And request
    """
    {
      "title": "Sample Title",
      "poLineId": "#(poLineId1)",
      "instanceId": "f1b57aeb-23c9-4386-bcb8-efda56878267",
      "contributors": [
        {
          "contributor": "Ed Mashburn",
          "contributorNameTypeId": "fbdd42a8-e47d-4694-b448-cc571d1b44c3"
        }
      ],
      "publisher": "Schiffer Publishing",
      "publishedDate": "1972",
      "edition": "Third Edt.",
      "subscriptionFrom": "2018-10-09T00:00:00.000Z",
      "subscriptionInterval": 824,
      "subscriptionTo": "2020-10-09T00:00:00.000Z",
      "claimingActive": false,
      "claimingInterval": 0,
      "isAcknowledged": true,
      "productIds": [
        {
          "productId": "9780764354113",
          "productIdType": "8261054f-be78-422d-bd51-4ed9f33c3422",
          "qualifier": "(paperback)"
        }
      ],
      "acqUnitIds": ["#(acqUnitId2)"]
    }
    """
    When method POST
    Then status 403

  Scenario: Repeat the same step with assigning acqUnit2 to user but make them inactive - POST Title operation should be also forbidden
    # 1. Create acq unit
    * configure headers = headersAdmin
    Given path 'acquisitions-units/units'
    And headers headersAdmin
    And request
    """
    {
      "id": '#(acqUnitId2)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "name": "testAcqUnit2"
    }
    """
    When method POST
    Then status 201

    # 2. Create acq unit membership
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId3)',
        "userId": "00000000-1111-5555-9999-999999999992",
        "acquisitionsUnitId": "#(acqUnitId2)"
      }
    """
    When method POST
    Then status 201

    # 3. Make acqUnit2 inactive
    Given path 'acquisitions-units/units', acqUnitId2
    And request
    """
    {
      "id": '#(acqUnitId2)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "isDeleted": true,
      "name": "testAcqUnit2"
    }
    """
    When method PUT
    Then status 204

    # 4. Verify POST Title to be forbidden
    * configure headers = headersUser
    Given path 'orders/titles'
    And request
    """
    {
      "title": "Sample Title",
      "poLineId": "#(poLineId1)",
      "instanceId": "f1b57aeb-23c9-4386-bcb8-efda56878267",
      "contributors": [
        {
          "contributor": "Ed Mashburn",
          "contributorNameTypeId": "fbdd42a8-e47d-4694-b448-cc571d1b44c3"
        }
      ],
      "publisher": "Schiffer Publishing",
      "publishedDate": "1972",
      "edition": "Third Edt.",
      "subscriptionFrom": "2018-10-09T00:00:00.000Z",
      "subscriptionInterval": 824,
      "subscriptionTo": "2020-10-09T00:00:00.000Z",
      "claimingActive": false,
      "claimingInterval": 0,
      "isAcknowledged": true,
      "productIds": [
        {
          "productId": "9780764354113",
          "productIdType": "8261054f-be78-422d-bd51-4ed9f33c3422",
          "qualifier": "(paperback)"
        }
      ],
    }
    """
    When method POST
    Then status 403

  Scenario: Make acqUnit2 as active and repeat step again - operation should be allowed
    # 1. Make acqUnit2 active
    * configure headers = headersAdmin
    Given path 'acquisitions-units/units', acqUnitId2
    And request
    """
    {
      "id": '#(acqUnitId2)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "isDeleted": false,
      "name": "testAcqUnit2"
    }
    """
    When method PUT
    Then status 204

    # 2. Create acq unit membership
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId5)',
        "userId": "00000000-1111-5555-9999-999999999992",
        "acquisitionsUnitId": "#(acqUnitId2)"
      }
    """
    When method POST
    Then status 201

    # 2. POST Title
    Given path 'orders/titles'
    And request
    """
    {
      "title": "Sample Title",
      "poLineId": "#(poLineId1)",
      "instanceId": "f1b57aeb-23c9-4386-bcb8-efda56878267",
      "contributors": [
        {
          "contributor": "Ed Mashburn",
          "contributorNameTypeId": "fbdd42a8-e47d-4694-b448-cc571d1b44c3"
        }
      ],
      "publisher": "Schiffer Publishing",
      "publishedDate": "1972",
      "edition": "Third Edt.",
      "subscriptionFrom": "2018-10-09T00:00:00.000Z",
      "subscriptionInterval": 824,
      "subscriptionTo": "2020-10-09T00:00:00.000Z",
      "claimingActive": false,
      "claimingInterval": 0,
      "isAcknowledged": true,
      "productIds": [
        {
          "productId": "9780764354113",
          "productIdType": "8261054f-be78-422d-bd51-4ed9f33c3422",
          "qualifier": "(paperback)"
        }
      ],
      "acqUnitIds": ["#(acqUnitId2)"]
    }
    """
    When method POST
    Then status 201

  ## Receive/Edit piece checks
  Scenario: Verify Edit piece functionality
    # Assign acqUnit1 to Order, open and receive this Order. Assign acqUnit2 to related Title.
    # Prepare user that has only acqUnit1, try to edit related piece - operation should be forbidden
    # because for any operation with piece we check acq unit from related Title, and user does not have acqUnit2 assigned.
     # 4. Create a composite order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId2)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      acqUnitIds: ['#(acqUnitId1)']
    }
    """
    When method POST
    Then status 201

    # 5. Create an order line
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # Open the order
    Given path 'orders/composite-orders', orderId2
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId2
    And request order
    When method PUT
    Then status 204

    # Receive the piece
    # Get the id of piece created when the order was opened
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    # Receive it
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId)",
              itemStatus: "In process",
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId2)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1
    * call pause 500

    # 1. Create acq unit to assign to title
    * configure headers = headersAdmin
    Given path 'acquisitions-units/units'
    And request
    """
    {
      "id": '#(acqUnitId3)',
      "protectUpdate": true,
      "protectCreate": true,
      "protectDelete": true,
      "protectRead": true,
      "name": "testAcqUnit3"
    }
    """
    When method POST
    Then status 201

    # Retrieve title and assign acqUnit2
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.acqUnitIds[0] = acqUnitId3
    * def titleId = $.titles[0].id

    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 204

    # Check piece 1 receivingStatus
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.displayOnHolding == false
    And match $.enumeration == "#(pieceId)"
    And match $.chronology == "#(pieceId)"
    And match $.supplement == true
    And match $.discoverySuppress == true
    And match $.displayOnHolding == false

    * def pieceResponse = $
    * set pieceResponse.caption = 'Edition 2'

    Given path 'orders/pieces', pieceId
    And request pieceResponse
    When method PUT
    Then status 204

  Scenario: Verify receive and create piece functionality
    # Do the same preparation, but instead of editing Piece make call receive the piece and
    # to create new piece - both operations should be forbidden
    * configure headers = headersAdmin
    * print 'Create a new location'
    Given path 'locations'
    And request
    """
    {
        "id": "#(locationId)",
        "name": "#(locationId)",
        "code": "#(locationId)",
        "isActive": true,
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [
            "3a40852d-49fd-4df2-a1f9-6e2641a6e91f"
        ]
    }
    """
    When method POST
    Then status 201

    * configure headers = headersUser
    * print 'Check titles'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId2
    When method GET
    And match $.totalRecords == 1
    * def titleId = response.titles[0].id

    * print 'Create a piece'
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId1)",
      format: "Physical",
      locationId: "#(locationId)",
      poLineId: "#(poLineId2)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201

    * print 'Receive the piece'
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId1)",
              itemStatus: "In process",
              locationId: "#(locationId)"
            }
          ],
          poLineId: "#(poLineId2)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 403

  Scenario: Verify after assign acqUnit3 to user, now all previous operations should be allowed
    # 1. Create acq unit 'acqUnit3' membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
    """
      {
        "id": '#(acqUnitMembershipId4)',
        "userId": "00000000-1111-5555-9999-999999999992",
        "acquisitionsUnitId": "#(acqUnitId3)"
      }
    """
    When method POST
    Then status 201

    * print 'Receive the piece'
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId1)",
              itemStatus: "In process",
              locationId: "#(locationId)"
            }
          ],
          poLineId: "#(poLineId2)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 201
    And match $.receivingResults[0].processedSuccessfully == 1

    * print 'Check piece receivingStatus'
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'