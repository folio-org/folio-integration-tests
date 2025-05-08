  # For MODINVOICE-586
  Feature: Invoice with identical adjustments

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

      * call variables


    Scenario: Create, approve, pay and cancel an invoice with identical invoice-level adjustments
      * def fundId = call uuid
      * def budgetId = call uuid
      * def invoiceId = call uuid
      * def invoiceLineId = call uuid

      * print "1. Create finances"
      * configure headers = headersAdmin
      * def v = call createFund { id: '#(fundId)' }
      * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

      * print "2. Create the invoice"
      * configure headers = headersUser
      * def adj1 =
      """
        {
          "type": "Amount",
          "description": "adj1",
          "prorate": "Not prorated",
          "fundDistributions": [
            {
              "distributionType": "amount",
              "fundId": "#(fundId)",
              "value": 1
            }
          ],
          "value": 1,
          "relationToTotal": "In addition to"
        }
      """
      * copy adj2 = adj1
      * set adj2.description = "adj2"
      * def adjustments = [ "#(adj1)", "#(adj2)" ]
      * def v = call createInvoice { id: "#(invoiceId)", adjustments: "#(adjustments)" }

      * print "3. Add an invoice line"
      * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", fundId: "#(fundId)", total: 10 }

      * print "4. Approve the invoice"
      * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

      * print "5. Pay the invoice"
      * def v = call payInvoice { invoiceId: "#(invoiceId)" }

      * print "6. Cancel the invoice"
      * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }
