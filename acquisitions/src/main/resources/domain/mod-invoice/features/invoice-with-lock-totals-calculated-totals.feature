Feature: Check invoice and invoice lines total amount calculation, when adjustment exists and lockTotal set

  Background:
    * url baseUrl
    # uncomment below line for development
    * callonce dev {tenant: 'test_invoices1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoiceLines/to-check-invoice-and-invoice-lines-deletion-restrictions.json')

    # initialize common invoice data
    * def firstInvoiceId = callonce uuid1
    * def secondInvoiceId = callonce uuid2
    * def firstInvoiceLineId = callonce uuid3
    * def secondInvoiceLineId = callonce uuid4
    
#    * def firstInvoiceLineId = "34ead894-57a0-4276-8801-87fc7851f935"
#    * def firstInvoiceLineId = "34ead894-57a0-4276-8801-87fc7851f535"
#    * def secondInvoiceLineId = "34ead894-57a0-4276-8801-87fc7851f665"


  Scenario: Create invoice with lockTotal and not prorated adjustment
    * set invoicePayload.id = firstInvoiceLineId
    * set invoicePayload.lockTotal = 12.34
    * set invoicePayload.adjustments[0] = {"description": "Adjustment for API test", "type": "Amount", "value": 10, "prorate": "Not prorated", "relationToTotal": "In addition to" }
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 10.0
    And match $.lockTotal == 12.34
    And match $.subTotal == 0.0
    And match $.total == 10.0


  Scenario: Add percentage and amount adjustments to invoice
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    * def invoiceBody = $

    Given path 'invoice/invoices' , firstInvoiceLineId
    * set invoiceBody.adjustments[1] = {'description': 'Adjustment for API test', 'type': 'Percentage', 'value': 25, 'prorate': 'Not prorated', 'relationToTotal': 'In addition to' }
    * set invoiceBody.adjustments[2] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 25, 'prorate': 'Not prorated', 'relationToTotal': 'In addition to' }
    * set invoiceBody.adjustments[3] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 100, 'prorate': 'Not prorated', 'relationToTotal': 'Included in' }
    * set invoiceBody.adjustments[4] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 50, 'prorate': 'Not prorated', 'relationToTotal': 'Separate from' }    # ============= create invoice ===================
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Check amount and totals in the invoice
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    And match $.adjustments == '#[5]'
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 35.0
    And match $.lockTotal == 12.34
    And match $.subTotal == 0.0
    And match $.total == 35.0

  Scenario: Add first invoice line with adjustment to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = firstInvoiceLineId
    * set invoiceLinePayload.firstInvoiceLineId = firstInvoiceLineId
    * set invoiceLinePayload.subTotal = 54.32
    * set invoiceLinePayload.adjustments[0] = {'description': 'Adjustment for API test', 'type': 'Percentage', 'value': -11, 'prorate': 'Not prorated', 'relationToTotal': 'In addition to' }
    * set invoiceLinePayload.adjustments[1] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 21.35, 'prorate': 'Not prorated', 'relationToTotal': 'In addition to' }
    * set invoiceLinePayload.adjustments[2] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 10, 'prorate': 'Not prorated', 'relationToTotal': 'Included in' }

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 15.37
    And match $.subTotal == 54.32
    And match $.total == 69.69

  Scenario: Verify invoice line totals persisted
    Given path 'invoice/invoice-lines'
    And param query = 'firstInvoiceLineId==' + firstInvoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLines[0].adjustmentsTotal == 15.37
    And match $.invoiceLines[0].subTotal == 54.32
    And match $.invoiceLines[0].total == 69.69

  Scenario: 1. Verify invoice totals are updated
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    And match $.adjustmentsTotal == 63.95
    And match $.subTotal == 54.32
    And match $.lockTotal == 12.34
    And match $.total == 118.27

  Scenario: Add second invoice line with adjustment to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = secondInvoiceLineId
    * set invoiceLinePayload.firstInvoiceLineId = firstInvoiceLineId
    * set invoiceLinePayload.subTotal = 15.87
    * set invoiceLinePayload.adjustments[0] = {'description': 'Adjustment for API test', 'type': 'Amount', 'value': 6.65, 'prorate': 'Not prorated', 'relationToTotal': 'In addition to' }

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 6.65
    And match $.subTotal == 15.87
    And match $.total == 22.52

  Scenario: Verify two invoice line totals persisted
    Given path 'invoice/invoice-lines'
    And param query = 'firstInvoiceLineId==' + firstInvoiceLineId
    When method GET
    Then status 200
    * def adjustmentsTotals = $.invoiceLines[0,1].adjustmentsTotal
    * def subTotals = $.invoiceLines[0,1].subTotal
    * def totals = $.invoiceLines[0,1].total
    And match $.invoiceLines == '#[2]'
    And match (adjustmentsTotals) contains any [15.37, 6.65]
    And match (subTotals) contains any [54.32, 15.87]
    And match (totals) contains any [69.69, 22.52]

  Scenario: 2. Verify invoice totals are updated
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    And match $.adjustmentsTotal == 22.02 + 35 + 17.55
    And match $.subTotal == 70.19
    And match $.lockTotal == 12.34
    And match $.total == 144.76

  Scenario: Update second line by removing adjustments
    Given path 'invoice/invoice-lines' , secondInvoiceLineId
    When method GET
    Then status 200
    * def secondInvoiceLine = $

    Given path 'invoice/invoice-lines' , secondInvoiceLineId
    * set secondInvoiceLine.adjustments = []
    * set secondInvoiceLine.subTotal = 8.13
    And request secondInvoiceLine
    When method PUT
    Then status 204

  Scenario: Verify second invoice line totals updated
    Given path 'invoice/invoice-lines'
    And param query = 'firstInvoiceLineId==' + firstInvoiceLineId
    When method GET
    Then status 200
    * def adjustmentsTotals = $.invoiceLines[0,1].adjustmentsTotal
    * def subTotals = $.invoiceLines[0,1].subTotal
    * def totals = $.invoiceLines[0,1].total
    And match $.invoiceLines == '#[2]'
    And match (adjustmentsTotals) contains any [15.37, 0.0]
    And match (subTotals) contains any [54.32, 8.13]
    And match (totals) contains any [69.69, 8.13]

  Scenario: Verify invoice totals are updated - by query
    Given path 'invoice/invoices'
    And param query = 'id==' + firstInvoiceLineId
    When method GET
    Then status 200
    And match $.invoices[0].adjustmentsTotal == 65.98
    And match $.invoices[0].subTotal == 62.45
    And match $.invoices[0].lockTotal == 12.34
    And match $.invoices[0].total == 128.43

  Scenario: Verify invoice totals are updated - by id
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    And match $.adjustmentsTotal == 65.98
    And match $.subTotal == 62.45
    And match $.lockTotal == 12.34
    And match $.total == 128.43

  Scenario: Delete second invoice line
     # ============= try to delete approved invoice line ===================
    Given path 'invoice/invoice-lines', secondInvoiceLineId
    When method DELETE
    Then status 204

  Scenario: Get invoice lines for invoice - only one left
    Given path 'invoice/invoice-lines'
    And param query = 'firstInvoiceLineId==' + firstInvoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLines == '#[1]'
    And match $.invoiceLines[0].adjustmentsTotal == 15.37
    And match $.invoiceLines[0].subTotal == 54.32
    And match $.invoiceLines[0].total == 69.69

  Scenario: Verify invoice totals are updated by query after line deletion
    Given path 'invoice/invoices'
    And param query = 'id==' + firstInvoiceLineId
    When method GET
    Then status 200
    And match $.invoices[0].adjustmentsTotal == 63.95
    And match $.invoices[0].subTotal == 54.32
    And match $.invoices[0].lockTotal == 12.34
    And match $.invoices[0].total == 118.27

  Scenario: Verify invoice totals are updated by id after line deletion
    Given path 'invoice/invoices', firstInvoiceLineId
    When method GET
    Then status 200
    And match $.adjustmentsTotal == 63.95
    And match $.subTotal == 54.32
    And match $.lockTotal == 12.34
    And match $.total == 118.27

  Scenario: Create second invoice with and 3 types of adjustments
    * set invoicePayload.id = secondInvoiceLineId
    * set invoicePayload.lockTotal = 12.34
    * set invoicePayload.adjustments[0] = {"description": "Adjustment for API test", "type": "Amount", "value": 10, "prorate": "Not prorated", "relationToTotal": "In addition to" }
    * set invoicePayload.adjustments[1] = {"description": "Adjustment for API test", "type": "Amount", "value": 10, "prorate": "By line", "relationToTotal": "In addition to" }
    * set invoicePayload.adjustments[2] = {"description": "Adjustment for API test", "type": "Amount", "value": 10, "prorate": "By quantity", "relationToTotal": "In addition to" }

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 30.0
    And match $.lockTotal == 12.34
    And match $.subTotal == 0.0
    And match $.total == 30.0