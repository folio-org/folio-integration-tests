@parallel=false
Feature: Piece batch job testing

  Background:
    * print karate.info.scenarioName

    * url baseUrl
#    * callonce dev {tenant: 'testorders1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 5000 }

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def orderId3 = callonce uuid5
    * def orderId4 = callonce uuid6
    * def orderId5 = callonce uuid7
    * def orderId6 = callonce uuid8
    * def poLineId1 = callonce uuid9
    * def poLineId2 = callonce uuid10
    * def poLineId3 = callonce uuid11
    * def poLineId4 = callonce uuid12
    * def poLineId5 = callonce uuid13
    * def poLineId6 = callonce uuid14
    * def currentDate = call isoDate
    * def previousDate = '2024-01-23T12:50:03.156+00:00'

  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }

  Scenario Outline: Create 6 orders
    * def orderId = <orderId>
    * def v = call createOrder { id: #(orderId) }

    Examples:
    | orderId  |
    | orderId1 |
    | orderId2 |
    | orderId3 |
    | orderId4 |
    | orderId5 |
    | orderId6 |

  Scenario Outline: Create 6 order lines
    * print "Create 6 order lines"

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
    | orderId3 | poLineId3 |
    | orderId4 | poLineId4 |
    | orderId5 | poLineId5 |
    | orderId6 | poLineId6 |

  Scenario Outline: Open 6 orders
    * def orderId = <orderId>
    * def v = call openOrder { orderId: #(orderId) }

    Examples:
      | orderId  |
      | orderId1 |
      | orderId2 |
      | orderId3 |
      | orderId4 |
      | orderId5 |
      | orderId6 |

  Scenario Outline: Update statuses in pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = <receivingStatus>
    * set piece.claimingInterval = <claimingInterval>

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def piece = $

    * set piece.receiptDate = <receiptDate>
    * set piece.statusUpdatedDate = <statusUpdatedDate>

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Examples:
      | poLineId  | receivingStatus | receiptDate  | statusUpdatedDate | claimingInterval |
      | poLineId1 | 'Expected'      | previousDate | currentDate       | 1                |
      | poLineId2 | 'Claim delayed' | currentDate  | previousDate      | 1                |
      | poLineId3 | 'Claim sent'    | currentDate  | previousDate      | 1                |
      | poLineId4 | 'Expected'      | currentDate  | currentDate       | 1                |
      | poLineId5 | 'Claim delayed' | currentDate  | currentDate       | 1                |
      | poLineId6 | 'Claim sent'    | currentDate  | currentDate       | 1                |

  Scenario: Update piece status based on intervals
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200

    * call pause 3000

  Scenario Outline: Validate pieces statuses after update
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    And match piece.receivingStatus == <receivingStatus>

    Examples:
    | poLineId  | receivingStatus |
    | poLineId1 | 'Late'          |
    | poLineId2 | 'Late'          |
    | poLineId3 | 'Late'          |
    | poLineId4 | 'Expected'      |
    | poLineId5 | 'Claim delayed' |
    | poLineId6 | 'Claim sent'    |

  Scenario Outline: Check audit statuses history for pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + <poLineId>
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    And retry until response.totalItems == <eventQuantity>
    When method GET
    Then status 200
    And match $.totalItems == <eventQuantity>

    Examples:
      | poLineId  | eventQuantity |
      | poLineId1 | 3             |
      | poLineId2 | 3             |
      | poLineId3 | 3             |
      | poLineId4 | 2             |
      | poLineId5 | 2             |
      | poLineId6 | 2             |