Feature: Create voucher lines for each unique : externalAccountNumber-extensionNumber

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }
    * configure readTimeout = 600000
    * configure headers = headersUser
  #-------------- Init global variables and load templates. !Variables must be before templates initialization --------
    * callonce variables
    * callonce read('classpath:global/load-shared-templates.feature')

  Scenario Outline: Assign expense classes to budgets for <budgetId>, <expenseClassId>

    * def budgetId = <budgetId>
    * def expenseClassId = <expenseClassId>

    * configure headers = headersAdmin

    Given path 'finance-storage/budget-expense-classes'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "expenseClassId": "#(expenseClassId)",
      "status": 'Active'
    }
    """
    When method POST
    Then status 201

    Examples:
      | budgetId         | expenseClassId           |
      | globalBudgetId   | globalElecExpenseClassId |
      | globalBudgetId2  | globalElecExpenseClassId |
      | globalBudgetId3  | globalElecExpenseClassId |
      | globalBudgetId   | globalPrnExpenseClassId  |
      | globalBudgetId2  | globalPrnExpenseClassId  |
      | globalBudgetId3  | globalPrnExpenseClassId  |


  Scenario: Checking that one voucher lines are created with two fundDistr and expense class ext number is included in the voucherLine.externalAccountNumber

    Given path 'invoice/invoices'
    * copy newInvoice =  invoiceTemplate
    And request newInvoice
    When method POST
    Then status 201
    * def invoiceId = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine1 = percentageInvoiceLineTemplate
    * set invoiceLine1.invoiceId = invoiceId
    And request invoiceLine1
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine2 = percentageInvoiceLineTemplate
    * set invoiceLine2.invoiceId = invoiceId
    And request invoiceLine2
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoicePayload.id
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def voucherLine = $.voucherLines[0]
    * def fundDistributions = voucherLine.fundDistributions[0,1]
    And match $.voucherLines == '#[1]'
    And match voucherLine.fundDistributions == '#[2]'
    And match voucherLine.voucherId == voucher.id
    And match voucherLine.externalAccountNumber == '1111111111111111111111111-01'
    And match ([fundDistributions.fundId]) contains any ['#(globalFundId)']
    And match ([fundDistributions.expenseClassId]) contains any ['#(globalElecExpenseClassId)']
    And match ([fundDistributions.invoiceLineId]) contains any [ '#(invoiceLineId1)' , '#(invoiceLineId2)' ]


  Scenario: Checking that one voucher lines are created with two fundDistr with same voucherLine.externalAccountNumber
    Given path 'invoice/invoices'
    * copy newInvoice = invoiceTemplate
    And request newInvoice
    When method POST
    Then status 201
    * def invoiceId = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine1 = percentageInvoiceLineTemplate
    * set invoiceLine1.invoiceId = invoiceId
    * remove invoiceLine1.fundDistributions[0].expenseClassId
    And request invoiceLine1
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine2 = percentageInvoiceLineTemplate
    * set invoiceLine2.invoiceId = invoiceId
    * remove invoiceLine2.fundDistributions[0].expenseClassId
    And request invoiceLine2
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoicePayload.id
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def voucherLine = $.voucherLines[0]
    * def externalAccountNumbers = voucherLine.externalAccountNumber
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")
    And match $.voucherLines == '#[1]'
    And match externalAccountNumbers == '1111111111111111111111111'
    And match fundDistributions1[0].fundId == fundDistributions2[0].fundId


  Scenario: Checking that two voucher lines are created and in each line there is fundDistr with unique voucherLine.externalAccountNumber
    Given path 'invoice/invoices'
    * copy newInvoice = invoiceTemplate
    And request newInvoice
    When method POST
    Then status 201
    * def invoiceId = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine1 = percentageInvoiceLineTemplate
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.fundDistributions[0].expenseClassId = globalElecExpenseClassId
    And request invoiceLine1
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine2 = percentageInvoiceLineTemplate
    * set invoiceLine2.invoiceId = invoiceId
    * set invoiceLine2.fundDistributions[0].expenseClassId = globalPrnExpenseClassId
    And request invoiceLine2
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoicePayload.id
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def externalAccountNumbers = $.voucherLines[0,1].externalAccountNumber
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")
    And match $.voucherLines == '#[2]'
    And match (externalAccountNumbers) contains any [ '1111111111111111111111111-01','1111111111111111111111111-02' ]
    And match fundDistributions1[0].expenseClassId == globalElecExpenseClassId
    And match fundDistributions2[0].expenseClassId == globalPrnExpenseClassId


  Scenario: Checking that two voucher lines are created and in each line there is fundDistr with unique voucherLine.externalAccountNumber
    Given path 'invoice/invoices'
    * copy newInvoice = invoiceTemplate
    And request newInvoice
    When method POST
    Then status 201
    * def invoiceId = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine1 = percentageInvoiceLineTemplate
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.fundDistributions[0].expenseClassId = globalElecExpenseClassId
    * set invoiceLine1.fundDistributions[0].fundId = globalFundId2
    And request invoiceLine1
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine2 = percentageInvoiceLineTemplate
    * set invoiceLine2.invoiceId = invoiceId
    * set invoiceLine2.fundDistributions[0].expenseClassId = globalPrnExpenseClassId
    And request invoiceLine2
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoicePayload.id
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def externalAccountNumbers = $.voucherLines[0,1].externalAccountNumber
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")
    And match $.voucherLines == '#[2]'
    And match (externalAccountNumbers) contains any [ '1111111111111111111111111-01','1111111111111111111111111-02' ]
    And match fundDistributions1[0].expenseClassId == globalElecExpenseClassId
    And match fundDistributions2[0].expenseClassId == globalPrnExpenseClassId

  Scenario: Checking that two voucher lines are created and in each line there is fundDistr with the same voucherLine.externalAccountNumber
    Given path 'invoice/invoices'
    * copy newInvoice = invoiceTemplate
    And request newInvoice
    When method POST
    Then status 201
    * def invoiceId = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine1 = percentageInvoiceLineTemplate
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.fundDistributions[0].fundId = globalFundId3
    * remove invoiceLine1.fundDistributions[0].expenseClassId
    And request invoiceLine1
    When method POST
    Then status 201
    * def invoiceLineId1 = $.id

    # ============= Create lines ===================
    Given path 'invoice/invoice-lines'
    * copy invoiceLine2 = percentageInvoiceLineTemplate
    * set invoiceLine2.invoiceId = invoiceId
    And request invoiceLine2
    When method POST
    Then status 201
    * def invoiceLineId2 = $.id

    # ============= approve invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status 204

    # ============= Verify voucher lines ===================
    Given path '/voucher/vouchers'
    And param limit = '2147483647'
    And param query = 'invoiceId==' + invoicePayload.id
    When method GET
    Then status 200
    * def voucher = $.vouchers[0]

    Given path '/voucher/voucher-lines'
    And param limit = '1000'
    And param query = 'voucherId==' + voucher.id
    When method GET
    Then status 200
    * def externalAccountNumbers = $.voucherLines[0,1].externalAccountNumber
    * def fundDistributions1 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId1 + "')]")
    * def fundDistributions2 = karate.jsonPath(response, "$.voucherLines[0,1].fundDistributions[?(@.invoiceLineId == '" + invoiceLineId2 + "')]")
    And match $.voucherLines == '#[2]'
    And match (externalAccountNumbers) contains any [ '1111111111111111111111111-01' ]
    And match fundDistributions2[0].expenseClassId == globalElecExpenseClassId
    And match $.voucherLines[0].externalAccountNumber == $.voucherLines[1].externalAccountNumber