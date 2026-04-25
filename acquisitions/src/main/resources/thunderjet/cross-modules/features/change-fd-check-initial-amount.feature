# For MODORDERS-842
@parallel=false
Feature: Change fund distribution and check initial amount encumbered

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundAId = callonce uuid1
    * def fundBId = callonce uuid2
    * def fundCId = callonce uuid3
    * def fundDId = callonce uuid4
    * def budgetAId = callonce uuid5
    * def budgetBId = callonce uuid6
    * def budgetCId = callonce uuid7
    * def budgetDId = callonce uuid8
    * def orderId = callonce uuid9
    * def poLineId = callonce uuid10
    * def invoiceId = callonce uuid11
    * def invoiceLineId = callonce uuid12


  Scenario: Prepare finances with 4 funds
    * def v = call createFund { id: '#(fundAId)' }
    * def v = call createFund { id: '#(fundBId)' }
    * def v = call createFund { id: '#(fundCId)' }
    * def v = call createFund { id: '#(fundDId)' }
    * def v = call createBudget { id: '#(budgetAId)', fundId: '#(fundAId)', allocated: 100 }
    * def v = call createBudget { id: '#(budgetBId)', fundId: '#(fundBId)', allocated: 100 }
    * def v = call createBudget { id: '#(budgetCId)', fundId: '#(fundCId)', allocated: 100 }
    * def v = call createBudget { id: '#(budgetDId)', fundId: '#(fundDId)', allocated: 100 }


  Scenario: Create an order and line using fund A and fund B
    * def v = call createOrder { id: '#(orderId)' }

    * table fundDistribution
      | fundId  | code    | distributionType | value |
      | fundAId | fundAId | 'percentage'     | 50    |
      | fundBId | fundBId | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', listUnitPrice: 10, fundDistribution: '#(fundDistribution)' }


  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }


  Scenario: Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }


  Scenario: Add an invoice line linked to the po line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceAId = poLine.fundDistribution[0].encumbrance
    * def encumbranceBId = poLine.fundDistribution[1].encumbrance

    * table fundDistributions
      | fundId  | encumbrance    | distributionType | value |
      | fundAId | encumbranceAId | 'percentage'     | 50    |
      | fundBId | encumbranceBId | 'percentage'     | 50    |

    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fundDistributions)', poLineId: '#(poLineId)', total: 10.0 }


  Scenario: Approve and pay the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }


  Scenario: Change the po line fund distribution using funds C B and D
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $

    * set poLine.fundDistribution[0].fundId = fundCId
    * set poLine.fundDistribution[0].code = fundCId
    * set poLine.fundDistribution[0].value = 30.0
    * remove poLine.fundDistribution[0].encumbrance
    * set poLine.fundDistribution[1].fundId = fundBId
    * set poLine.fundDistribution[1].code = fundBId
    * set poLine.fundDistribution[1].value = 30.0
    * set poLine.fundDistribution[2].fundId = fundDId
    * set poLine.fundDistribution[2].code = fundDId
    * set poLine.fundDistribution[2].distributionType = 'percentage'
    * set poLine.fundDistribution[2].value = 40.0

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Check encumbrances initialAmountEncumbered
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 3
    * def transactionC = karate.jsonPath(response, "$.transactions[?(@.fromFundId=='"+fundCId+"')]")[0]
    * def transactionB = karate.jsonPath(response, "$.transactions[?(@.fromFundId=='"+fundBId+"')]")[0]
    * def transactionD = karate.jsonPath(response, "$.transactions[?(@.fromFundId=='"+fundDId+"')]")[0]
    And match transactionC.encumbrance.initialAmountEncumbered == 3
    And match transactionB.encumbrance.initialAmountEncumbered == 3
    And match transactionD.encumbrance.initialAmountEncumbered == 4
