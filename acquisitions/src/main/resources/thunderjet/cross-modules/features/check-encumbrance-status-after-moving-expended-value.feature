# For MODORDERS-943
@parallel=false
Feature: Check encumbrance status after moving expended value

  # 1) create 4 identical funds
  # 2) create a purchase order
  # 3) create purchase order line with fund distributions: fund1(50%) and fund2(50%)
  # 4) open the newly create PO
  # 5) create and pay an invoice with flag releaseEncumbrance = true
  # 6) change fund distributions:
  #        1) replace fund1 to fund3 and decrease distribution value to 30%,
  #        2) for fund2 decrease distribution value to 30%,
  #        3) add fund4 and set distribution value 40%
  # 7) check statuses and amounts after PUT operation

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid3
    * def fundId4 = callonce uuid4
    * def budgetId1 = callonce uuid5
    * def budgetId2 = callonce uuid6
    * def budgetId3 = callonce uuid7
    * def budgetId4 = callonce uuid8
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8

  Scenario Outline: Prepare finances
    * def fundId = <fundId>
    * def fundCode = <fundCode>
    * def budgetId = <budgetId>
    * def v = call createFund { id: '#(fundId)', code: '#(fundCode)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    Examples:
      | fundId  | fundCode    | budgetId  |
      | fundId1 | 'fundCode1' | budgetId1 |
      | fundId2 | 'fundCode2' | budgetId2 |
      | fundId3 | 'fundCode3' | budgetId3 |
      | fundId4 | 'fundCode4' | budgetId4 |


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)' }

  Scenario: Create a po line
    * table fundDistribution
      | fundId  | code        | distributionType | value |
      | fundId1 | 'fundCode1' | 'percentage'     | 50    |
      | fundId2 | 'fundCode2' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', paymentStatus: 'Awaiting Payment', fundDistribution: '#(fundDistribution)' }

  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

  Scenario: Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

  Scenario: Create an invoice line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId1 = poLine.fundDistribution[0].encumbrance
    * def encumbranceId2 = poLine.fundDistribution[1].encumbrance

    * print "Add an invoice line linked to the po line"
    * table fundDistributions
    | fundId  | code        | encumbrance    | distributionType | value |
    | fundId1 | 'fundCode1' | encumbranceId1 | 'percentage'     | 50    |
    | fundId2 | 'fundCode2' | encumbranceId2 | 'percentage'     | 50    |

    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fundDistributions)', poLineId: '#(poLineId)', total: 1, releaseEncumbrance: true }

  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

  Scenario: Update fundId in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.fundDistribution[0].fundId = fundId3
    * set poLine.fundDistribution[0].code = 'fundCode3'
    * set poLine.fundDistribution[0].value = 30
    * set poLine.fundDistribution[1].value = 30
    * set poLine.fundDistribution[2] = { fundId:'#(fundId4)', code: 'fundCode4', distributionType:'percentage', value: 40 }
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

  Scenario Outline: Check the newly created encumbrance
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def newEncumbranceId = $.fundDistribution[<index>].encumbrance

    Given path 'finance/transactions', newEncumbranceId
    When method GET
    Then status 200
    And match $.amount == <amount>
    And match $.encumbrance.amountExpended == <amountExpended>
    And match $.encumbrance.status == <status>

    Examples:
      | index | amount | amountExpended | status       |
      | 0     | 0      | 0.5            | 'Released'   |
      | 1     | 0      | 0.5            | 'Released'   |
      | 2     | 0.4    | 0              | 'Unreleased' |
