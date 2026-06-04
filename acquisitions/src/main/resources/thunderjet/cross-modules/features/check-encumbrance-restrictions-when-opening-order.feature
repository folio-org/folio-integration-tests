# For MODFISTO-472, FAT-12169, FAT-21155, https://foliotest.testrail.io/index.php?/cases/view/449361,
# https://foliotest.testrail.io/index.php?/cases/view/503053
Feature: Check encumbrance restrictions when opening an order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 5000 }

    * callonce variables

    # Create finance data common to all tests (ledger with restricted encumbrance, fund A, budget A
    # with $100 allocated, +$10 net transfer, allowable encumbrance/expenditure 110%)
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def v = call createLedger { id: '#(ledgerId)', restrictEncumbrance: true, restrictExpenditures: false }
    * def v = call createFund { id: '#(fundAId)', name: 'Fund A', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetAId)', fundId: '#(fundAId)', allocated: 100, netTransfers: 10, allowableEncumbrance: 110.0, allowableExpenditure: 110.0 }

    # 1. Create order #1 ($10) and open it -> encumbered $10 on fund A
    * def order1Id = call uuid
    * def poLine1Id = call uuid
    * def v = call createOrder { id: '#(order1Id)', orderType: 'One-Time' }
    * table polineRows1
      | id          | orderId    | fundId    | listUnitPrice | titleOrPackage |
      | poLine1Id   | order1Id   | fundAId   | 10.0          | 'Order 1 line' |
    * call createOrderLine polineRows1
    * def v = call openOrder { orderId: '#(order1Id)' }

    # 2. Create invoice #1 (NOT from order #1) and approve it for $15 -> awaitingPayment $15
    * def invoice1Id = call uuid
    * def invoiceLine1Id = call uuid
    * def v = call createInvoice { id: '#(invoice1Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine1Id)', invoiceId: '#(invoice1Id)', fundId: '#(fundAId)', total: 15.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice1Id)' }

  @C449361
  @Positive
  Scenario: Order can be opened when balance is close to the encumbered available balance
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid
    * def order2Id = call uuid
    * def poLine2Id = call uuid

    # 3. Create invoice #2 (NOT from order #1) and pay it for $20 -> expended $20
    * def v = call createInvoice { id: '#(invoice2Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine2Id)', invoiceId: '#(invoice2Id)', fundId: '#(fundAId)', total: 20.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice2Id)' }
    * def v = call payInvoice { invoiceId: '#(invoice2Id)' }

    # 4. Verify budget values
    Given path 'finance/budgets', budgetAId
    When method GET
    Then status 200
    And match $.allocated == 100.00
    And match $.netTransfers == 10.00
    And match $.encumbered == 10.00
    And match $.awaitingPayment == 15.00
    And match $.expenditures == 20.00

    # 5. Create order #2 in Pending status with one PO line of $75 on fund A
    * def v = call createOrder { id: '#(order2Id)', orderType: 'One-Time' }
    * call createOrderLine { id: '#(poLine2Id)', orderId: '#(order2Id)', fundId: '#(fundAId)', listUnitPrice: 75.0 }

    # 6. Open order #2 - remaining allowed encumbrance = (100+10)*1.1 - (10+15+20) = 76, so $75 fits
    * def v = call openOrder { orderId: '#(order2Id)' }

    # 7. Verify order #2 is Open and PO line current encumbrance = $75
    Given path 'orders/composite-orders', order2Id
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 75.00 && response.totalEncumbered == 75.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 8. Verify encumbrance details for order #2 PO line
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order2Id
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def tr = $.transactions[0]
    And match tr.encumbrance.sourcePoLineId == poLine2Id
    And match tr.transactionType == 'Encumbrance'
    And match tr.amount == 75.00
    And match tr.fromFundId == fundAId
    And match tr.encumbrance.sourcePurchaseOrderId == order2Id
    And match tr.encumbrance.status == 'Unreleased'
    And match tr.encumbrance.initialAmountEncumbered == 75.00
    And match tr.encumbrance.amountAwaitingPayment == 0.00
    And match tr.encumbrance.amountExpended == 0.00

    # 9. Verify final fund A budget values after opening order #2
    Given path 'finance/budgets', budgetAId
    When method GET
    Then status 200
    And match $.allocated == 100.00
    And match $.netTransfers == 10.00
    And match $.encumbered == 85.00
    And match $.awaitingPayment == 15.00
    And match $.expenditures == 20.00

  @C503053
  @Negative
  Scenario:  Order can NOT be opened when encumbered amount exceeding remaining allowed encumbrances
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid
    * def invoice3Id = call uuid
    * def invoiceLine3Id = call uuid
    * def order2Id = call uuid
    * def poLine2Id = call uuid

    # 3. Create invoice #2 (NOT from order #1) and pay it with a $25 expense for fund A
    * def v = call createInvoice { id: '#(invoice2Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine2Id)', invoiceId: '#(invoice2Id)', fundId: '#(fundAId)', total: 25.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice2Id)' }
    * def v = call payInvoice { invoiceId: '#(invoice2Id)' }

    # 4. Create invoice #3 (NOT from order #1) and pay it with a $5 credit for fund A
    * def v = call createInvoice { id: '#(invoice3Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine3Id)', invoiceId: '#(invoice3Id)', fundId: '#(fundAId)', total: -5.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice3Id)' }
    * def v = call payInvoice { invoiceId: '#(invoice3Id)' }

    # 5. Create order #2 in Pending status with one PO line of $77 on fund A
    * def v = call createOrder { id: '#(order2Id)', orderType: 'One-Time' }
    * call createOrderLine { id: '#(poLine2Id)', orderId: '#(order2Id)', fundId: '#(fundAId)', listUnitPrice: 77.0 }

    # 6. Verify budget values before trying to open
    Given path 'finance/budgets', budgetAId
    When method GET
    Then status 200
    And match $.allocated == 100.00
    And match $.netTransfers == 10.00
    And match $.encumbered == 10.00
    And match $.awaitingPayment == 15.00
    And match $.expenditures == 25.00
    And match $.credits == 5.00

    # 7. Try to open order #2: it should fail; check error message
    Given path 'orders/composite-orders', order2Id
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'
    * remove order.poLines
    Given path 'orders/composite-orders', order2Id
    And request order
    When method PUT
    Then status 422
    And match $.errors[0].code == 'fundCannotBePaid'
    And match $.errors[0].parameters[0].value == '[' + fundAId + ']'

    # 8. Check order status was not changed
    Given path 'orders/composite-orders', order2Id
    When method GET
    Then status 200
    And match $.workflowStatus == 'Pending'

    # 9. Check no encumbrance was created
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order2Id
    When method GET
    Then status 200
    And match $.totalRecords == 0
