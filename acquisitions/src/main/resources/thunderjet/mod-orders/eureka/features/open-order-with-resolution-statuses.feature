# For MODORDERS-1170
Feature: Close order if order line has resolution statuses that should make it as closed

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def fundId = callonce uuid
    * def budgetId = callonce uuid
    * def orderId = callonce uuid
    * def poLineId = callonce uuid

  @Positive
  Scenario: Oper order with resolution statuses that should make it as closed
    # 1. Create fund and budget
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 100 }

    # 2. Create an order
    * def v = call createOrder { id: #(orderId) }

    # 3. Create an order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), paymentStatus: 'Payment Not Required', receiptStatus: 'Receipt Not Required' }

    # 4. Open the order
    * def v = call openOrder { orderId: #(orderId) }

    # 5. Check the order was closed, because paymentStatus and receiptStatus are 'Awaiting Payment' and 'Awaiting Receipt'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

    # 6. Check the encumbrance after closing the order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def transaction = response.transactions[0]
    And assert transaction.amount == 0.0
    And assert transaction.encumbrance.initialAmountEncumbered == 1.0
    And assert transaction.encumbrance.status == 'Released'
