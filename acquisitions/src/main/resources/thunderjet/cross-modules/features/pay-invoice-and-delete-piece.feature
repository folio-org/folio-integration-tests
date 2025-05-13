#MODORDERS-833
Feature: Pay an invoice and delete a piece

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId = callonce uuid6

    # Prepare finances
    * callonce createFund { id: #(fundId) }
    * callonce createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }

  Scenario: Pay an invoice and delete a piece
    # 1. Create an order
    * def v = call createOrder { id: #(orderId) }

    # 2. Create an order line
    * table locations
      | locationId         | quantity | quantityPhysical |
      | globalLocationsId  | 2        | 2                |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 2, locations: '#(locations)' }

    # 3. Open the order
    * def v = call openOrder { orderId: #(orderId) }

    # 4. Receive the piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
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

    # 5. Create an invoice
    * def v = call createInvoice { id: #(invoiceId) }

    # 6. Add an invoice line
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0] = { fundId:'#(fundId)', code:'#(fundId)', distributionType:'percentage', value:100 }
    * set invoiceLine.total = 1
    * set invoiceLine.subTotal = 1
    * set invoiceLine.releaseEncumbrance = true

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    # 7. Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    # 8. Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }

    # 9. Delete the piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def pieceId = $.pieces[0].id

    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204

    # 10. Check the budget encumbrance
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match response.budgets[0].encumbered == 0