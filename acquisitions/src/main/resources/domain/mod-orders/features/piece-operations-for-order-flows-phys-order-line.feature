# for https://issues.folio.org/browse/MODORDERS-568
Feature: Test operations affecting pieces for physical po line with different options

  # This test does the following operations for all cases given in the data table at the end:
  # - Create finances
  # - Create an instance when an instance will be connected to the po line
  # - Create a holdings when the po line will use a holdings location
  # - Create an order
  # - Create an order line
  # - Open the order
  # - Get the instanceId and holdingId from the po line
  # - Check if a piece was created when the order was opened
  # - Check holdings
  # - Check items
  # - Check titles
  # - Create a piece
  # - Receive the piece
  # - Check piece receivingStatus
  # - Check the quantity in the order line
  # - Unreceive the piece
  # - Check the unreceived piece status
  # - Update the piece
  # - Delete the piece
  # - Unopen the order
  # - Check order line after unopen
  # - Check items after unopen
  # - Reopen the order
  # - Check order line after reopen
  # - Check po line pieces after reopen
  # - Check holdings after reopen
  # - Check items after reopen
  # - Check titles after reopen
  # - Delete the order line
  # - Check titles after deleting the order line
  # - Check pieces after deleting the order line
  # - Check holdings after deleting the order line
  # - Check items after deleting the order line

  Background:
    * url baseUrl
    * callonce dev {tenant: 'test_orders1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def initialInstanceId = call uuid
    * def locationId = globalLocationsId
    * def initialHoldingId = call uuid
    * def updatedHoldingId = call uuid
    * def pieceId = call uuid
    * def packageTitleId = call uuid
    * def noLocation = []
    * def normalLocation = [ { "locationId": "#(locationId)", "quantity": 2, "quantityPhysical": 2 } ]
    * def holdingLocation = [ { "holdingId": "#(initialHoldingId)", "quantity": 2, "quantityPhysical": 2 } ]


  Scenario Outline: Piece operations
    * print 'Piece operations: instance =', instance, ' inventory =', inventory, ' locations =', locations, ' checkinItems =', checkinItems, ' isPackage =', isPackage
    * def withItem = <inventory>.contains('Item')
    * def withHolding = <inventory>.contains('Holding')

    * print 'Create finances'
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)'}

    # When an instance is connected to the po line
    * if (<instance> || locations == 'holdingLocation') karate.log('Create an instance (for cases with a connected instance or a holding location)')
    * if (<instance> || locations == 'holdingLocation') karate.call('../reusable/create-instance.feature', { instanceId: initialInstanceId, title: 'Interesting Times', instanceTypeId: globalInstanceTypeId })

    # When a holdings was given for a location
    * if (locations == 'holdingLocation') karate.log('Create holdings (for cases with a holdings location)')
    * if (locations == 'holdingLocation') karate.call('../reusable/create-holdings.feature', { holdingId: initialHoldingId, instanceId: initialInstanceId, locationId: locationId })

    * print 'Create an order'
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    * print 'Create an order line'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.physical.createInventory = <inventory>
    * set poLine.instanceId = <instance> ? initialInstanceId : null
    * set poLine.locations = <locations>
    * set poLine.checkinItems = <checkinItems>
    * set poLine.isPackage = <isPackage>
    * set poLine.cost.quantityPhysical = 2
    * set poLine.eresource.createInventory = locations == 'noLocation' ? 'None' : 'Instance, Holding, Item'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print 'Open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations.length == 0 ? initialHoldingId : response.locations[0].holdingId

    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == <checkinItems> ? 0 : 2
    * def physicalPieces = $.pieces[?(@.format == 'Physical')]
    * def physicalPiece = physicalPieces.length == 0 ? null : physicalPieces[0]
    And assert <checkinItems> || physicalPiece.receivingStatus == 'Expected'
    And assert <checkinItems> || (withItem && physicalPiece.itemId != null) || (!withItem && physicalPiece.itemId == null)
    And assert <checkinItems> || (withHolding && physicalPiece.holdingId == holdingId) || (!withHolding && physicalPiece.holdingId == null)

    * print 'Check holdings'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    # If we only had physical, there could be a holdings if it was given as a location or if it had to be created when opening the pol
    # And match $.totalRecords == (withHolding || locations == 'holdingLocation') && !<isPackage> ? 1 : 0
    # Because of the electronic part, there is always a holdings except for packages and when the pol has no location
    And match $.totalRecords == !<isPackage> && locations != 'noLocation' ? 1 : 0
    And assert <locations>.length == 0 || <locations>[0].holdingId == undefined || response.holdingsRecords[0].id == initialHoldingId

    * print 'Check items'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    # No item is created if pieces are added manually
    # A physical item is created only if inventory contains Item
    # An electronic item is created if there is a location (in this case its inventory contains Item)
    And match $.totalRecords == (!<checkinItems> && withItem ? 1 : 0) + (!<checkinItems> && locations != 'noLocation' ? 1 : 0)
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItem = physicalItems.length == 0 ? null : physicalItems[0]
    And assert (!<checkinItems> && withItem) ? physicalItem != null : physicalItem == null
    And assert physicalItem == null || physicalItem.holdingsRecordId == holdingId
    And assert physicalItem == null || physicalItem.status.name == 'On order'

    * if (<isPackage>) karate.log('Create a title (for isPackage only)')
    * if (<isPackage>) karate.call('../reusable/create-title.feature', { titleId: packageTitleId, poLineId })

    * configure headers = headersUser
    * print 'Check titles'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def titleId = response.titles[0].id


    * print 'Create a piece'
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      locationId: "#(locationId)",
      poLineId: "#(poLineId)",
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
              id: "#(pieceId)",
              itemStatus: "In process",
              locationId: "#(locationId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    * print 'Check piece receivingStatus'
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'

    * print 'Check the quantity in the order line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.locations == '#[1]'
    And match $.locations[0].quantityPhysical == <checkinItems> ? 1 : 2
    And match $.locations[0].quantity == <checkinItems> ? 2 : 3

    * print 'Unreceive the piece'
    Given path 'orders/receive'
    And request
    """
    {
      toBeReceived: [
        {
          "poLineId": "#(poLineId)",
          "received": 1,
          "receivedItems": [
            {
              "itemStatus": "On order",
              "pieceId": "#(pieceId)"
            }
          ]
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    * print 'Check the unreceived piece status'
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'

    * print 'Update the piece'
    Given path 'orders/pieces', pieceId
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      holdingId: "#(updatedHoldingId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method PUT
    Then status 204

    * print 'Delete the piece'
    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204


    * print 'Unopen the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Pending'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    * print 'Check order line after unopen'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    # it's OK here if instanceId is null and response.instanceId is undefined
    And assert response.instanceId == instanceId
    # holdings should be preserved during unopen
    And assert response.locations.length == 0 || response.locations[0].holdingId == holdingId

    * print 'Check items after unopen'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    # "on order" items for expected pieces should be removed by unopen
    And match $.totalRecords == 0


    * print 'Reopen the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    * print 'Check order line after reopen'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And assert response.instanceId == instanceId
    And assert response.locations.length == 0 || response.locations[0].holdingId == holdingId

    * print 'Check po line pieces after reopen'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == <checkinItems> ? 0 : 2
    * def physicalPieces = $.pieces[?(@.format == 'Physical')]
    * def physicalPiece = physicalPieces.length == 0 ? null : physicalPieces[0]
    And assert <checkinItems> || physicalPiece.receivingStatus == 'Expected'
    And assert <checkinItems> || (withItem && physicalPiece.itemId != null) || (!withItem && physicalPiece.itemId == null)
    And assert <checkinItems> || (withHolding && physicalPiece.holdingId == holdingId) || (!withHolding && physicalPiece.holdingId == null)

    * print 'Check holdings after reopen'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == !<isPackage> && locations != 'noLocation' ? 1 : 0
    And assert <locations>.length == 0 || <locations>[0].holdingId == undefined || response.holdingsRecords[0].id == initialHoldingId

    * print 'Check items after reopen'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == (!<checkinItems> && withItem ? 1 : 0) + (!<checkinItems> && locations != 'noLocation' ? 1 : 0)
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItem = physicalItems.length == 0 ? null : physicalItems[0]
    And assert (!<checkinItems> && withItem) ? physicalItem != null : physicalItem == null
    And assert physicalItem == null || physicalItem.holdingsRecordId == holdingId
    And assert physicalItem == null || physicalItem.status.name == 'On order'

    * print 'Check titles after reopen'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    And match $.totalRecords == 1


    * print 'Delete the order line'
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

    * print 'Check titles after deleting the order line'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    And match $.totalRecords == 0

    * print 'Check pieces after deleting the order line'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check holdings after deleting the order line'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == !<isPackage> && locations != 'noLocation' ? 1 : 0

    * print 'Check items after deleting the order line'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    # All the items have the "On Order" status and should be removed.
    And match $.totalRecords == 0
    # NOTE: items with status other than "On Order" or "Pending order" should not be removed (this is not tested yet)


    # instance = instance is connected to po line
    # inventory = inventory change for physical only (electronic is always 'Instance, Holding, Item')
    # checkinItems = "Manually add pieces for receiving"
    Examples:
      | instance | inventory                 | locations       | checkinItems | isPackage |
      | false    | 'None'                    | normalLocation  | false        | false     |
#      | false    | 'None'                    | normalLocation  | true         | false     |
#      | false    | 'None'                    | normalLocation  | true         | true      |
#      | false    | 'None'                    | noLocation      | true         | true      |
#      | false    | 'Instance, Holding, Item' | normalLocation  | false        | false     |
#      | false    | 'Instance, Holding, Item' | normalLocation  | true         | false     |
#      | false    | 'Instance, Holding, Item' | normalLocation  | true         | true      |
#      | true     | 'None'                    | noLocation      | false        | false     |
#      | true     | 'None'                    | normalLocation  | false        | false     |
#      | true     | 'Instance, Holding'       | normalLocation  | false        | false     |
#      | true     | 'Instance, Holding'       | normalLocation  | true         | false     |
#      | true     | 'Instance, Holding'       | holdingLocation | false        | false     |
#      | true     | 'Instance, Holding'       | holdingLocation | true         | false     |
#      | true     | 'Instance, Holding, Item' | normalLocation  | false        | false     |
#      | true     | 'Instance, Holding, Item' | normalLocation  | true         | false     |
#      | true     | 'Instance, Holding, Item' | holdingLocation | false        | false     |
#      | true     | 'Instance, Holding, Item' | holdingLocation | true         | false     |

