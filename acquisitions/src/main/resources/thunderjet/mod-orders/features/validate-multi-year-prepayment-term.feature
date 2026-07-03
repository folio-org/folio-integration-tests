# For MODORDERS-1428
Feature: Validate Multi-Year Prepayment Term Against Fiscal Year Distributions

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

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * configure headers = headersAdmin
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }
    * configure headers = headersUser

  @Negative
  Scenario: Create PO Line With Less Fiscal Year Distributions Than Prepayment Term
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def poLineId = call uuid
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * def paymentTerms = { totalPrice: 100.0, prepaymentTerm: 2, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    * set poLine.paymentTerms = paymentTerms

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'fiscalYearDistributionCountMismatch'
    And match $.errors[0].parameters contains { key: 'prepaymentTerm', value: '2' }
    And match $.errors[0].parameters contains { key: 'fiscalYearDistributionCount', value: '1' }


  @Negative
  Scenario: Update PO Line To Have Mismatched Fiscal Year Distributions Count
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def poLineId = call uuid
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * def paymentTerms = { totalPrice: 100.0, prepaymentTerm: 1, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    * set poLine.paymentTerms = paymentTerms

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * def createdPoLine = response
    * set createdPoLine.paymentTerms.prepaymentTerm = 2

    Given path 'orders/order-lines', poLineId
    And request createdPoLine
    When method PUT
    Then status 422
    And match $.errors[*].code contains 'fiscalYearDistributionCountMismatch'
    And match $.errors[0].parameters contains { key: 'prepaymentTerm', value: '2' }
    And match $.errors[0].parameters contains { key: 'fiscalYearDistributionCount', value: '1' }


  @Positive
  Scenario: Create PO Line With Fiscal Year Distributions Matching Prepayment Term
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def poLineId = call uuid
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * def paymentTerms = { totalPrice: 100.0, prepaymentTerm: 1, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    * set poLine.paymentTerms = paymentTerms

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    And match $.multiYearPayment == true
    And match $.paymentTerms.prepaymentTerm == 1
    And match $.paymentTerms.fiscalYearDistributions[0].fiscalYearId == globalFiscalYearId


  @Positive
  Scenario: Create PO Line With MultiYear Payment Disabled Ignores Distribution Count Mismatch
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def poLineId = call uuid
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = false
    * def paymentTerms = { totalPrice: 100.0, prepaymentTerm: 2, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    * set poLine.paymentTerms = paymentTerms

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    And match $.multiYearPayment == false
