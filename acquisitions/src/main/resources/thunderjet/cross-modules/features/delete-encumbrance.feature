Feature: Test deleting an encumbrance

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testcrossmodules'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * callonce variables
    * def orderId1 = callonce uuid1
    * def orderId2 = callonce uuid2
    * def orderId3 = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8


  Scenario: Delete an encumbrance successfully
    * print "Delete an encumbrance successfully"

    # retrieve budge info for later
    Given path '/finance/budgets', globalBudgetId
    And headers headersUser
    When method GET
    Then status 200
    * def budgetBefore = $

    # create a pending encumbrance transaction
    Given path 'finance-storage/order-transaction-summaries'
    And headers headersAdmin
    And request
    """
      {
        "id": '#(orderId1)',
        "numTransactions": 1
      }
    """
    When method POST
    Then status 201


    Given path 'finance/encumbrances'
    And headers headersUser
    And request
    """
      {
        "amount": 10,
        "currency": "USD",
        "description": "PO_Line: History of Incas",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId": "#(globalFundId)",
        "transactionType": "Encumbrance",
        "encumbrance" : {
          "initialAmountEncumbered": 10,
          "amountExpended": 0,
          "status": "Pending",
          "orderType": "One-Time",
          "subscription": false,
          "reEncumber": false,
          "sourcePurchaseOrderId": '#(orderId1)',
          "sourcePoLineId": '#(poLineId1)'
        }
      }
    """
    When method POST
    Then status 201
    * def transaction = $

    # release the encumbrance
    * set transaction.encumbrance.status = "Released"
    Given path 'finance/release-encumbrance', transaction.id
    And headers headersUser
    And request {}
    When method POST
    Then status 204

    # delete the encumbrance
    Given path 'finance/encumbrances', transaction.id
    And headers headersUser
    When method DELETE
    Then status 204

    # check the transaction is gone
    Given path 'finance/transactions', transaction.id
    And headers headersUser
    And request transaction
    When method GET
    Then status 404

    # check the budget's encumbered total was updated
    Given path '/finance/budgets', globalBudgetId
    And headers headersUser
    When method GET
    Then status 200
    And match $.encumbered == budgetBefore.encumbered


  Scenario: Test Error when trying to delete an encumbrance linked to an invoice
    * print "Test Error when trying to delete an encumbrance linked to an invoice"
    # create order
    Given path 'orders/composite-orders'
    And headers headersUser
    And request
    """
    {
      id: '#(orderId3)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    # create order line
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId3
    * set poLine.purchaseOrderId = orderId3
    * set poLine.fundDistribution[0].fundId = globalFundId
    Given path 'orders/order-lines'
    And headers headersUser
    And request poLine
    When method POST
    Then status 201

    # open order
    Given path 'orders/composite-orders', orderId3
    And headers headersUser
    When method GET
    Then status 200
    * def order = $
    * set order.workflowStatus = 'Open'


    Given path 'orders/composite-orders', orderId3
    And headers headersUser
    And request order
    When method PUT
    Then status 204

    # get order line info for later
    Given path 'orders/order-lines', poLineId3
    And headers headersUser
    When method GET
    Then status 200
    * def fd = $.fundDistribution
    * def encumbranceId = fd[0].encumbrance
    * def lineAmount = $.cost.listUnitPrice

    # create invoice
    Given path 'invoice/invoices'
    And headers headersUser
    And request
    """
    {
        "id": "#(invoiceId)",
        "chkSubscriptionOverlap": true,
        "currency": "USD",
        "source": "User",
        "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
        "status": "Open",
        "invoiceDate": "2020-05-21",
        "vendorInvoiceNo": "test",
        "accountingCode": "G64758-74828",
        "paymentMethod": "Physical Check",
        "vendorId": "#(globalVendorId)"
    }
    """
    When method POST
    Then status 201

    # Create invoice line
    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request
    """
    {
        "id": "#(invoiceLineId)",
        "invoiceId": "#(invoiceId)",
        "poLineId": "#(poLineId3)",
        "invoiceLineStatus": "Open",
        "fundDistributions": #(fd),
        "subTotal": #(lineAmount),
        "description": "test",
        "quantity": "1"
    }
    """
    When method POST
    Then status 201

    # approve invoice
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'


    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    And request invoice
    When method PUT
    Then status 204

    # try to delete the encumbrance
    Given path 'finance/encumbrances', encumbranceId
    And headers headersUser
    When method DELETE
    Then status 422

