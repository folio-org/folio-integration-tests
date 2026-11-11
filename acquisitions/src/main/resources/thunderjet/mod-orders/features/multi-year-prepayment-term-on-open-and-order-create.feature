# For MODORDERS-1428, https://foliotest.testrail.io/index.php?/cases/view/1621346, https://foliotest.testrail.io/index.php?/cases/view/1621347, https://foliotest.testrail.io/index.php?/cases/view/1621348, https://foliotest.testrail.io/index.php?/cases/view/1621349
Feature: Multi-Year Prepayment Term Validation On Order Opening And Composite Order Creation

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
    * configure retry = { count: 10, interval: 500 }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * configure headers = headersAdmin
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }
    * configure headers = headersUser


  @C1621346
  @Negative
  Scenario: Opening An Order With A Multi-Year PO Line Whose Fiscal Year Distributions Do Not Match The Prepayment Term Is Rejected
    * def orderId = call uuid
    * def poLineId = call uuid

    # Prerequisites: Pending Order With A PO Line Accepted Because Multi-Year Payment Is Off
    * def v = call createOrder { id: '#(orderId)' }
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = false
    * set poLine.paymentTerms = { totalPrice: 100.0, prepaymentTerm: 2, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 1. Enable Multi-Year Payment Directly In Storage
    Given path 'orders-storage/po-lines', poLineId
    When method GET
    Then status 200
    * def storagePoLine = response
    * set storagePoLine.multiYearPayment = true
    Given path 'orders-storage/po-lines', poLineId
    And request storagePoLine
    When method PUT
    Then status 204

    # 2. Try To Open The Order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = response
    * set order.workflowStatus = 'Open'
    * remove order.poLines
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 422
    And match $.errors[*].code contains 'fiscalYearDistributionCountMismatch'
    * def mismatchError = karate.filter(response.errors, function(e){ return e.code == 'fiscalYearDistributionCountMismatch' })[0]
    And match mismatchError.parameters contains { key: 'prepaymentTerm', value: '2' }
    And match mismatchError.parameters contains { key: 'fiscalYearDistributionCount', value: '1' }

    # 3. Order Stays Pending
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Pending'

    # 4. Nothing Is Encumbered
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.fundDistribution[0].encumbrance == '##null'


  @C1621347
  @Positive
  Scenario: Opening An Order With A Multi-Year PO Line Whose Fiscal Year Distributions Match The Prepayment Term Succeeds
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    # 1. Create A Multi-Year PO Line With One Distribution For A One-Year Term
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * set poLine.paymentTerms = { totalPrice: 100.0, prepaymentTerm: 1, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 2. Open The Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Order Is Open
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200

    # 4. Multi-Year Fields Are Kept And The Encumbrance Is Created
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.multiYearPayment == true
    And match $.paymentTerms.prepaymentTerm == 1
    And match $.paymentTerms.fiscalYearDistributions == '#[1]'
    And match $.paymentTerms.fiscalYearDistributions[0].fiscalYearId == globalFiscalYearId
    And match $.fundDistribution[0].encumbrance == '#uuid'


  @C1621348
  @Negative
  Scenario: Multi-Year PO Line With More Fiscal Year Distributions Than The Prepayment Term Is Rejected
    * def orderId = call uuid
    * def poLineId = call uuid
    * def fiscalYearId2 = call uuid
    * def series = call random_string

    # Prerequisites: Second Fiscal Year And A Pending Order
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: '#(fiscalYearId2)', code: '#(series + "0002")', periodStart: '2098-01-01T00:00:00Z', periodEnd: '2098-12-30T23:59:59Z', series: '#(series)' }
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 1. Try To Create A PO Line With Two Distributions For A One-Year Term
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * set poLine.paymentTerms = { totalPrice: 100.0, prepaymentTerm: 1, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }, { fiscalYearId: '#(fiscalYearId2)' }] }
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'fiscalYearDistributionCountMismatch'
    And match $.errors[0].parameters contains { key: 'prepaymentTerm', value: '1' }
    And match $.errors[0].parameters contains { key: 'fiscalYearDistributionCount', value: '2' }

    # 2. PO Line Is Not Created
    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  @C1621349
  @Negative
  Scenario: Composite Order With An Embedded Multi-Year PO Line With Mismatched Fiscal Year Distributions Is Not Created
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Try To Create A Composite Order With An Embedded Mismatched PO Line
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.multiYearPayment = true
    * set poLine.paymentTerms = { totalPrice: 100.0, prepaymentTerm: 2, startingFiscalYearId: '#(globalFiscalYearId)', fiscalYearDistributions: [{ fiscalYearId: '#(globalFiscalYearId)' }] }
    * def order = { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', poLines: ['#(poLine)'] }
    Given path 'orders/composite-orders'
    And request order
    When method POST
    Then status 422
    And match $.errors[*].code contains 'fiscalYearDistributionCountMismatch'

    # 2. Order Is Not Created
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 404
