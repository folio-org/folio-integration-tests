@parallel=false
Feature: Piece status transitions

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def poLineId1 = callonce uuid5
    * def poLineId2 = callonce uuid6
    * def currentDate = call isoDate
    * def previousDate = '2024-01-23T12:50:03.156+00:00'

  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }

  Scenario Outline: Create 2 orders
    * def orderId = <orderId>
    * def v = call createOrder { id: #(orderId) }

    Examples:
      | orderId  |
      | orderId1 |
      | orderId2 |

  Scenario Outline: Create 2 order lines
    * print "Create 2 order lines"

    * copy poLine = orderLineTemplate
    * set poLine.id = <poLineId>
    * set poLine.purchaseOrderId = <orderId>
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.cost.listUnitPrice = 10
    * set poLine.claimingActive = true
    * set poLine.claimingInterval = 1

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Examples:
      | orderId  | poLineId  |
      | orderId1 | poLineId1 |
      | orderId2 | poLineId2 |

  Scenario Outline: Open 2 orders
    * def orderId = <orderId>
    * def v = call openOrder { orderId: #(orderId) }

    Examples:
      | orderId  |
      | orderId1 |
      | orderId2 |

  Scenario Outline: Update statuses in pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = <receivingStatus>
    * set piece.receiptDate = <receiptDate>
    * set piece.claimingInterval = <claimingInterval>

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Examples:
      | poLineId  | receivingStatus | receiptDate  | claimingInterval |
      | poLineId1 | 'Claim sent'    | previousDate | 1                |
      | poLineId1 | 'Claim sent'    | currentDate  | 2                |
      | poLineId2 | 'Claim delayed' | currentDate  | 1                |
      | poLineId2 | 'Claim delayed' | currentDate  | 2                |

  Scenario Outline: Check audit statuses history for pieces
    * call pause 5000
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And match $.totalItems == <eventQuantity>

    Examples:
      | poLineId  | eventQuantity |
      | poLineId1 | 3             |
      | poLineId2 | 3             |

  Scenario Outline: Receive the piece
    * def poLineId = <poLineId>
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

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
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    Examples:
      | poLineId  |
      | poLineId1 |
      | poLineId2 |

  Scenario Outline: Unreceive pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Expected'
    * remove piece.locationId
    Given path 'orders/pieces', pieceId
    And param deleteHoldings = false
    And request piece
    When method PUT
    Then status 204

    Examples:
      | poLineId  |
      | poLineId1 |
      | poLineId2 |

  Scenario Outline: Pieces to Unreceivable
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Unreceivable'
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Examples:
      | poLineId  |
      | poLineId1 |
      | poLineId2 |

  Scenario Outline: Pieces to Expected
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Expected'
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Examples:
      | poLineId  |
      | poLineId1 |
      | poLineId2 |

  Scenario Outline: Check audit statuses history for pieces
    * call pause 5000
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And match $.totalItems == <eventQuantity>

    Examples:
      | poLineId  | eventQuantity |
      | poLineId1 | 7             |
      | poLineId2 | 7             |