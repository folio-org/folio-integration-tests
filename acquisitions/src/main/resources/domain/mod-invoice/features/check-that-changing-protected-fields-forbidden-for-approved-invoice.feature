Feature: Checking that it is impossible to pay for the invoice if no voucher for invoice

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
    * def invoiceLineId = callonce uuid2

#    * def invoiceId = "34ead894-57a0-4272-8802-87fc7851f715"
#    * def invoiceLineId = "34ead894-57a0-4273-8801-87fc7851f745"

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

  Scenario: Add invoice line to created invoice
     # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    * set invoiceLinePayload.id = invoiceLineId
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

  Scenario: Approve invoice with lock total which equal to calculated total
  Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

  Scenario: Currency change for approved invoice is forbidden
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.currency = "TUGRIK"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 400
    * def error =  $.errors[0]
    And match error.code == 'protectedFieldChanging'
    And match (error.protectedAndModifiedFields) contains any ['currency']

  Scenario: Quantity and subTotal change for approved invoice lines is forbidden
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLinePayload = $
    * set invoiceLinePayload.quantity = 10
    * set invoiceLinePayload.subTotal = 25.5

    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLinePayload
    When method PUT
    Then status 400
    * def error =  $.errors[0]
    And match error.code == 'protectedFieldChanging'
    And match (error.protectedAndModifiedFields) contains any ['quantity', 'subTotal']