# For MODFISTO-475, https://foliotest.testrail.io/index.php?/cases/view/451473
Feature: Encumbrance calculated correctly after cancelling paid credit Invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  @C451473
  @Positive
  Scenario: Cancel a paid invoice with a single credit
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    #========================================================================================================
    # Preconditions
    #========================================================================================================

    # 1. Active Fund having current budget with money allocation
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), allocated: 1000, fundId: #(fundId), status: 'Active' }

    # 2. Order in "Open" status with Total amount = $10, Fund distribution specified with Fund from precondition #1
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: 10 }
    * def v = call openOrder { orderId: #(orderId) }

    # 3. Invoice was created from Order from precondition #2 (get the encumbrance id from PO line)
    * def v = call createInvoice { id: #(invoiceId) }
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    # 4. Invoice line amount was edited to be -$5 (negative amount)
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: -5 }

    # 5. Invoice was Approved and Paid
    * def v = call approveInvoice { invoiceId: #(invoiceId) }
    * def v = call payInvoice { invoiceId: #(invoiceId) }

    # Check the credit before cancelling
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 5
    And match $.transactions[0].paymentEncumbranceId == encumbranceId

    # Check the encumbrance before cancelling
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.amountCredited == 5
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.status == 'Released'

    # Check the budget before cancelling
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1005
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 5
    And match $.cashBalance == 1005
    And match $.encumbered == 0

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # Step 1. Cancel invoice
    #         Expected: Successful toast message appears, Invoice status became "Cancelled"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == 'Cancelled'

    # Step 2. Click on Invoice line record in "Invoice lines" accordion
    #         Expected:
    #           - Invoice line details pane is opened
    #           - "Sub-total" is "-$5.00"
    #           - "Fund distribution" is specified with Fund from precondition #1
    #           - "Current encumbrance" is $10.00
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'
    And match $.subTotal == -5
    And match $.fundDistributions[0].fundId == fundId
    And match $.fundDistributions[0].encumbrance == encumbranceId

    # Verify the voided credit transaction
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 5

    # Step 3. Click on the link in "Current encumbrance" column of "Fund distribution" record
    #         Expected:
    #           - Transaction details pane is opened
    #           - "Initial encumbrance" is $10.00
    #           - "Expended" is $0.00
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.amountCredited == 0
    And match $.encumbrance.status == 'Unreleased'

    # Additional check: budget after cancelling
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10
