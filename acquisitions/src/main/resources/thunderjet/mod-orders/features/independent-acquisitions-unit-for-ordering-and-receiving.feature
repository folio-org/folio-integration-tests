# created for MODORDERS-982
@parallel=false
Feature: Independent acquisitions unit for ordering and receiving

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def testUser2 = { tenant: '#(testTenant)', name: 'test-user-2', password: 'test' }
    * table user2Permissions
      | name                                           |
      | 'orders.acquisitions-units-assignments.assign' |
      | 'orders.acquisitions-units-assignments.manage' |
      | 'orders.item.get'                              |
      | 'orders.item.put'                              |
      | 'orders.titles.collection.get'                 |
      | 'orders.titles.item.get'                       |
      | 'orders.titles.item.post'                      |
      | 'orders.titles.item.put'                       |
      | 'titles.acquisitions-units-assignments.assign' |
      | 'titles.acquisitions-units-assignments.manage' |
    * def v = callonce createAdditionalUser { testUser: '#(testUser2)',  userPermissions: '#(user2Permissions)' }

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * callonce login testUser2
    * def okapitokenUser2 = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersUser2 = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser2)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }

    * configure headers = headersAdmin
    * def res = callonce getUserIdByUsername { user: '#(testUser)' }
    * def testUserId = res.userId
    * def res = callonce getUserIdByUsername { user: '#(testUser2)' }
    * def testUser2Id = res.userId
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def orderId3 = callonce uuid5
    * def orderId4 = callonce uuid19
    * def poLineId1 = callonce uuid6
    * def poLineId2 = callonce uuid7
    * def poLineId3 = callonce uuid8
    * def poLineId4 = callonce uuid20
    * def pieceId3 = callonce uuid9
    * def pieceId4 = callonce uuid21
    * def acqUnitId1 = callonce uuid10
    * def acqUnitId2 = callonce uuid11
    * def acqUnitId3 = callonce uuid12
    * def acqUnitMembershipId1 = callonce uuid13
    * def acqUnitMembershipId2 = callonce uuid14
    * def acqUnitMembershipId3 = callonce uuid15
    * def acqUnitMembershipId4 = callonce uuid16
    * def acqUnitMembershipId5 = callonce uuid17
    * def acqUnitMembershipId6 = callonce uuid23
    * def locationId = callonce uuid18
    * def titleId1 = callonce uuid22


  Scenario Outline: Prepare acqUnits
    # 1. Create acq unit 'acqUnitId1', 'acqUnitId2' and 'acqUnitId3'
    * def acqUnitId = <acqUnitId>
    * def acqUnitName = <acqUnitName>

    * configure headers = headersAdmin
    Given path 'acquisitions-units/units'
    And request
      """
      {
        "id": "#(acqUnitId)",
        "protectUpdate": true,
        "protectCreate": true,
        "protectDelete": true,
        "protectRead": true,
        "name": "#(acqUnitName)"
      }
      """
    When method POST
    Then status 201

    Examples:
      | acqUnitId  | acqUnitName    |
      | acqUnitId1 | 'testAcqUnit1' |
      | acqUnitId2 | 'testAcqUnit2' |
      | acqUnitId3 | 'testAcqUnit3' |

  Scenario Outline: Prepare membership for testUser2 user only
    * def acqUnitMembershipId = <acqUnitMembershipId>
    * def acqUnitId = <acqUnitId>
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
      """
      {
        "id": '#(acqUnitMembershipId)',
        "userId": "#(testUser2Id)",
        "acquisitionsUnitId": "#(acqUnitId)"
      }
      """
    When method POST
    Then status 201

    Examples:
      | acqUnitMembershipId  | acqUnitId  |
      | acqUnitMembershipId5 | acqUnitId1 |
      | acqUnitMembershipId6 | acqUnitId2 |

  Scenario: Prepare Location, Finance and Budget
    # 1. Create location
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

    # 2. Create a fund and budget
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)' }
    * callonce createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active'}] }

  ## Acq units inheritance from Order checks
  Scenario: Create Order with acqUnit1, Create PO Line, check that acqUnit1 was inherited from Order to Title
    # 1. Create acq unit membership for testUser
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
      """
      {
        "id": '#(acqUnitMembershipId1)',
        "userId": "#(testUserId)",
        "acquisitionsUnitId": "#(acqUnitId1)"
      }
      """
    When method POST
    Then status 201

    # 2. Create a composite order 'orderId1' with already created fund, budget
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

    # 3. Create an order line 'poLineId1'
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId1
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # 4. Open the order
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 5. Check that acqUnt 'acqUnitId1' was inherited from Order to Title
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.titles[0].acqUnitIds[0] == acqUnitId1

  Scenario: Edit acq units for Order, change should NOT propagated to related Title
    # 1. Edit the composite order by removing acqUnit 'acqUnitId1'
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.acqUnitIds = []

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 2. Check title has acqUnit 'acqUnitId1'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.titles[0].acqUnitIds[0] == acqUnitId1

  Scenario: Edit acq units for Title, change should NOT propagated to related Order
    # 1. Assign acqUnit 'acqUnitId1' to order back
    * configure headers = headersUser2
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200

    * def order = $
    * set order.acqUnitIds = ['#(acqUnitId1)']

    Given path 'orders/composite-orders', orderId1
    And request order
    When method PUT
    Then status 204

    # 2. Remove acqUnit 'acqUnitId' from title
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

    # 3. Check that previous title operation should not be affect to order. It should have acqUnitIds
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId1
    When method GET
    Then status 200
    And match $.acqUnitIds[0] == acqUnitId1

  ## Title Acq units protection checks
  Scenario: Assign acqUnit1 to Title and remove acq unit from user membership to check that GET, PUT request for Title is forbidden
    # 1. Assign acqUnit 'acqUnitId1' to title
    * configure headers = headersUser2
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.acqUnitIds = ['#(acqUnitId1)']
    * def titleId = $.titles[0].id

    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 204

    # 2. Before remove acq unit verify GET request
    * configure headers = headersUser
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.title = "Updated title"
    * def titleId = $.titles[0].id

    # 3. Remove acq unit membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId1
    When method DELETE
    Then status 204

    # 4. Verify PUT request is not possible
    * configure headers = headersUser
    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 403
    And match $.errors[*].code == ['userNotAMemberOfTheAcq']
    And match $.errors[*].message == ['User is not a member of the specified acquisitions group - operation is restricted']

    # 5. Verify GET request is not possible
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: Assign acqUnit1 to user and check that both GET titles return our title and this title is editable now
    # 1. Assign acq unit membership to user
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
      """
      {
        "id": '#(acqUnitMembershipId2)',
        "userId": "#(testUserId)",
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
    * def titleId = $.titles[0].id
    * def poLineId = $.titles[0].poLineId
    * def acqUnitIds = $.titles[0].acqUnitIds

    # 3. Do PUT operation for title after re-assign acq unit membership
    * configure headers = headersUser2
    Given path 'orders/titles', titleId
    And request
      """
      {
        "id": "#(titleId)",
        "title": "Updated title",
        "poLineId": "#(poLineId)"
      }
      """
    When method PUT
    Then status 204

  ## Package Order checks
  Scenario: Create package order with acqUnit1 assigned,
  Create Title for this package order with acqUnit2, check that this POST Title operation is forbidden
    # 1. Create a composite order
    Given path 'orders/composite-orders'
    And request
      """
      {
        id: '#(orderId2)',
        vendor: '#(globalVendorId)',
        orderType: 'One-Time',
        "acqUnitIds": ['#(acqUnitId1)']
      }
      """
    When method POST
    Then status 201

    # 2. Create package order-line for order
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.isPackage = true
    * set poLine.checkinItems = true
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.fundDistribution[0].fundId = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 3. Create Title for this package order with acqUnit2, check that this POST Title operation is forbidden
    Given path 'orders/titles'
    And request
      """
      {
        id: "#(titleId1)",
        title: "Sample Title",
        poLineId: "#(poLineId2)",
        "acqUnitIds": ['#(acqUnitId2)']
      }
      """
    When method POST
    Then status 403
    And match $.errors[*].code == ['userHasNoAcqUnitsPermission']
    And match $.errors[*].message == ['User does not have permissions to manage acquisition units assignments - operation is restricted']

  Scenario: Repeat the same step with assigning acqUnit2 to user but make them inactive - POST Title operation should be also forbidden
    # 'acqUnitId2' has already been created
    # 1. Create acqUnit membership for user and 'acqUnitId2'
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
      """
      {
        "id": '#(acqUnitMembershipId3)',
        "userId": "#(testUserId)",
        "acquisitionsUnitId": "#(acqUnitId2)"
      }
      """
    When method POST
    Then status 201

    # 2. Make acqUnit2 inactive
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

    # 3. Verify POST Title to be forbidden
    * configure headers = headersUser2
    Given path 'orders/titles'
    And request
      """
      {
        id: "#(titleId1)",
        title: "Sample Title",
        poLineId: "#(poLineId2)",
        "acqUnitIds": ['#(acqUnitId2)']
      }
      """
    When method POST
    Then status 422

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

    # 2. POST Title
    * configure headers = headersUser2
    Given path 'orders/titles'
    And request
      """
      {
        id: "#(titleId1)",
        title: "Sample Title",
        poLineId: "#(poLineId2)",
        "acqUnitIds": ['#(acqUnitId2)']
      }
      """
    When method POST
    Then status 201

  ## Receive/Edit piece checks
  Scenario: Verify Edit piece functionality
  Assign acqUnit1 to Order, open and receive this Order. Assign acqUnit2 to related Title.
  Prepare user that has only acqUnit1, try to edit related piece - operation should be forbidden
  because for any operation with piece we check acq unit from related Title, and user does not have acqUnit2 assigned.

    # 1. Create a composite order. Now 'acqUnitId1' is assigned to user, acqUnitId2' is not assigned to user
    Given path 'orders/composite-orders'
    And request
      """
      {
        id: '#(orderId3)',
        vendor: '#(globalVendorId)',
        orderType: 'One-Time',
        acqUnitIds: ['#(acqUnitId1)']
      }
      """
    When method POST
    Then status 201

    # 2. Create an order line
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId3
    * set poLine.purchaseOrderId = orderId3
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # 3. Open the order
    Given path 'orders/composite-orders', orderId3
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId3
    And request order
    When method PUT
    Then status 204

    # 4. Receive the piece
    # 4.1 Get the id of piece created when the order was opened
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId3
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    # 4.2 Receive it
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
            poLineId: "#(poLineId3)"
          }
        ],
        totalRecords: 1
      }
      """
    When method POST
    Then status 200
    * call pause 500

    # 5. Retrieve title and assign acqUnit2
    * configure headers = headersUser2
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId3
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleResponse = $.titles[0]
    * set titleResponse.acqUnitIds = ['#(acqUnitId2)']
    * def titleId = $.titles[0].id

    Given path 'orders/titles', titleId
    And request titleResponse
    When method PUT
    Then status 204

    # 6. Remove acqUnit 'acqUnitId2' membership, user only has 'acqUnitId1'
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships', acqUnitMembershipId3
    When method DELETE
    Then status 204

    # 7. Check piece 1 receivingStatus and update the piece should be forbidden
    * configure headers = headersUser
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200

    * def pieceResponse = $
    * def pieceId = pieceResponse.id
    * set pieceResponse.displaySummary = 'Edition 2'
    * set pieceResponse.locationId = null

    Given path 'orders/pieces', pieceId
    And request pieceResponse
    When method PUT
    Then status 403
    And match $.errors[*].code == ['userNotAMemberOfTheAcq']
    And match $.errors[*].message == ['User is not a member of the specified acquisitions group - operation is restricted']

    # 8. Create piece should be forbidden
    * print 'Create a piece'
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceId4)",
        format: "Physical",
        locationId: "#(locationId)",
        poLineId: "#(poLineId3)",
        titleId: "#(titleId)"
      }
      """
    When method POST
    Then status 403
    And match $.errors[*].code == ['userNotAMemberOfTheAcq']
    And match $.errors[*].message == ['User is not a member of the specified acquisitions group - operation is restricted']

  Scenario: Verify after assign acqUnit2 to user, now all previous operations should be allowed
    # 1. Create acq unit 'acqUnit2' membership
    * configure headers = headersAdmin
    Given path 'acquisitions-units/memberships'
    And request
      """
      {
        "id": '#(acqUnitMembershipId4)',
        "userId": "#(testUserId)",
        "acquisitionsUnitId": "#(acqUnitId2)"
      }
      """
    When method POST
    Then status 201

    # 2. Create a composite order 'orderId4' with already created fund, budget
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
      """
      {
        id: '#(orderId4)',
        vendor: '#(globalVendorId)',
        orderType: 'One-Time',
        "acqUnitIds": ['#(acqUnitId1)']
      }
      """
    When method POST
    Then status 201

    # 3. Create an order line 'poLineId4'
    Given path 'orders/order-lines'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId4
    * set poLine.purchaseOrderId = orderId4
    * set poLine.fundDistribution[0].fundId = fundId
    And request poLine
    When method POST
    Then status 201

    # 4. Open the order
    Given path 'orders/composite-orders', orderId4
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId4
    And request order
    When method PUT
    Then status 204

    # 5. Receive the piece
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
                id: "#(pieceId4)",
                itemStatus: "In process",
                locationId: "#(locationId)"
              }
            ],
            poLineId: "#(poLineId4)"
          }
        ],
        totalRecords: 1
      }
      """
    When method POST
    Then status 200
