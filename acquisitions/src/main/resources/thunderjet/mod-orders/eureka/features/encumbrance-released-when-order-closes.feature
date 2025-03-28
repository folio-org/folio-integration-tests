@parallel=false
# for https://issues.folio.org/browse/MODORDERS-859
Feature: Encumbrance released when order closes

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 100 }


  Scenario: Create an order
    * def v = callonce createOrder { id: #(orderId) }


  Scenario: Create an order line with Payment Not Required
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = 'Payment Not Required'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * def v = callonce openOrder { orderId: "#(orderId)" }


  Scenario: Receive the piece
    # Get the id of piece created when the order was opened
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
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
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1
    * call pause 500


  Scenario: Check the order was closed
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'


  Scenario: Check the encumbrance was released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 1
