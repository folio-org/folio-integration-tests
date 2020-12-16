Feature: Checking that it is impossible to add a invoice line to already approved invoice

  Background:
    * url baseUrl
    # uncomment below line for development
   #* callonce dev {tenant: 'test_invoices1'}
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
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    # initialize common invoice data
     * def invoiceId = callonce uuid1
     * def firstInvoiceLineId = callonce uuid2
     * def secondInvoiceLineId = callonce uuid3

#    * def invoiceId = "34ead894-57a0-4276-8802-87fc7851f915"
#    * def firstInvoiceLineId = "34ead894-57a0-4276-8801-87fc7851f545"
#    * def secondInvoiceLineId = "34ead894-57a0-4276-8801-87fc7851f685"

  Scenario: Create invoice with lockTotal and without adjustment
    * set invoicePayload.id = invoiceId
    * set invoicePayload.lockTotal = 10.02
    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.lockTotal == 10.02
    And match $.subTotal == 0.0
    And match $.total == 0.0

  Scenario: Add first invoice line to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = firstInvoiceLineId
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.quantity = 1
    * set invoiceLinePayload.subTotal = 10.02
    * set invoiceLinePayload.total = 10.02
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId

    And request invoiceLinePayload
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 10.02
    And match $.total == 10.02

  # ============= approve invoice ===================
  Scenario: Approve invoice with lock total is not equal to calculated total
  Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

  Scenario: Add second invoice line to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = secondInvoiceLineId
    * set invoiceLinePayload.invoiceId = invoiceId
    * set invoiceLinePayload.quantity = 1
    * set invoiceLinePayload.subTotal = 11.02
    * set invoiceLinePayload.total = 11.02
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId

    And request invoiceLinePayload
    When method POST
    Then status 500
    And match $.errors[0].code == 'prohibitedInvoiceLineCreation'