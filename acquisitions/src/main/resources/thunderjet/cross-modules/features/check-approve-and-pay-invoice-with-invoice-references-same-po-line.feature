# For MODINVOICE-363
Feature: Check approve and pay invoice with more than 15 invoice lines, several of which reference to same POL

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    
  Scenario: Check approve and pay invoice with more than 15 invoice lines, several of which reference to same POL
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def invoiceLineId4 = call uuid
    * def invoiceLineId5 = call uuid
    * def invoiceLineId6 = call uuid
    * def invoiceLineId7 = call uuid
    * def invoiceLineId8 = call uuid
    * def invoiceLineId9 = call uuid
    * def invoiceLineId10 = call uuid
    * def invoiceLineId11 = call uuid
    * def invoiceLineId12 = call uuid
    * def invoiceLineId13 = call uuid
    * def invoiceLineId14 = call uuid
    * def invoiceLineId15 = call uuid
    * def invoiceLineId16 = call uuid
    * def invoiceLineId17 = call uuid
    * def invoiceLineId18 = call uuid
    * def invoiceLineId19 = call uuid
    * def invoiceLineId20 = call uuid
    * def invoiceLineId21 = call uuid
    * def invoiceLineId22 = call uuid
    * def invoiceLineId23 = call uuid
    * def invoiceLineId24 = call uuid
    * def invoiceLineId25 = call uuid
    * def invoiceLineId26 = call uuid
    * def invoiceLineId27 = call uuid
    * def invoiceLineId28 = call uuid
    * def invoiceLineId29 = call uuid
    * def invoiceLineId30 = call uuid
    
    # 1. Create finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Add invoice lines linked to the same POL
    * table invoiceLines
      | description       | invoiceLineId   |
      | 'invoice line 1'  | invoiceLineId1  |
      | 'invoice line 2'  | invoiceLineId2  |
      | 'invoice line 3'  | invoiceLineId3  |
      | 'invoice line 4'  | invoiceLineId4  |
      | 'invoice line 5'  | invoiceLineId5  |
      | 'invoice line 6'  | invoiceLineId6  |
      | 'invoice line 7'  | invoiceLineId7  |
      | 'invoice line 8'  | invoiceLineId8  |
      | 'invoice line 9'  | invoiceLineId9  |
      | 'invoice line 10' | invoiceLineId10 |
      | 'invoice line 11' | invoiceLineId11 |
      | 'invoice line 12' | invoiceLineId12 |
      | 'invoice line 13' | invoiceLineId13 |
      | 'invoice line 14' | invoiceLineId14 |
      | 'invoice line 15' | invoiceLineId15 |
      | 'invoice line 16' | invoiceLineId16 |
      | 'invoice line 17' | invoiceLineId17 |
      | 'invoice line 18' | invoiceLineId18 |
      | 'invoice line 19' | invoiceLineId19 |
      | 'invoice line 20' | invoiceLineId20 |
      | 'invoice line 21' | invoiceLineId21 |
      | 'invoice line 22' | invoiceLineId22 |
      | 'invoice line 23' | invoiceLineId23 |
      | 'invoice line 24' | invoiceLineId24 |
      | 'invoice line 25' | invoiceLineId25 |
      | 'invoice line 26' | invoiceLineId26 |
      | 'invoice line 27' | invoiceLineId27 |
      | 'invoice line 28' | invoiceLineId28 |
      | 'invoice line 29' | invoiceLineId29 |
      | 'invoice line 30' | invoiceLineId30 |

    * def total = 10.0
    * def v = call createInvoiceLineFromPoLine invoiceLines

    # 7. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 8. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }
