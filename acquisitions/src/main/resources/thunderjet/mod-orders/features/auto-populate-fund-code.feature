# For MODORDERS-981
Feature: Auto-populate fundCode in PO line fund distribution

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

    * call read('classpath:common/util/random_string.feature')
    * callonce variables

  @Positive
  Scenario: Create order with PO line fund distribution missing fundCode, expect it to be auto-populated
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def codePrefix = call random_string
    * def fundCode = 'FC-' + codePrefix

    # 1. Create finance data with admin headers
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create a pending order with line without fundCode
    * configure headers = headersUser
    * call createOrder { id: '#(orderId)' }

    * def fundDistribution = [{ fundId: '#(fundId)', distributionType: 'percentage', value: 100 }]
    * call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundDistribution: #(fundDistribution) }

    # 3. Verify that fundCode is not populated in pending order
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDistPending = response.fundDistribution[0]
    * match fundDistPending.fundCode == '#notpresent'

    # 4. Open order and verify that fundCode is auto-populated
    * call openOrder { orderId: '#(orderId)' }

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDist = response.fundDistribution[0]
    * match fundDist.code == fundCode

  @Positive
  Scenario: Create order with PO line fund distribution wrong fundCode, expect that fund code from Fund would be used
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def codePrefix = call random_string
    * def incorrectFundCode = 'IncorrectFC-' + codePrefix
    * def fundCode = 'FC-' + codePrefix

    # 1. Create finance data with admin headers
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }


    # 2. Create pending order with order line where fund code is not provided
    * configure headers = headersUser
    * call createOrder { id: '#(orderId)' }
    * def fundDistribution = [{ fundId: '#(fundId)', code: '#(incorrectFundCode)', distributionType: 'percentage', value: 100 }]
    * call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundDistribution: #(fundDistribution) }

    # 3. Verify that fundCode is now populated with correct value from fund
    * call openOrder { orderId: '#(orderId)' }

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDistOpen = response.fundDistribution[0]
    * match fundDistOpen.code == fundCode

  @Positive
  Scenario: Create and open order in single operation, expect fundCode to be auto-populated
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def codePrefix = call random_string
    * def fundCode = 'FC-' + codePrefix

    # 1. Create finance data with admin headers
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create open order with single operation without fund code populated
    * configure headers = headersUser
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.fundDistribution[0].code

    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": "#(orderId)",
      "vendor": "#(globalVendorId)",
      "orderType": "One-Time",
      "workflowStatus": "Open",
      "poLines": [
        #(poLine)
      ]
    }
    """
    When method POST
    Then status 201

    # 3. Check that fundCode is auto-populated
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDist = response.fundDistribution[0]
    * match fundDist.code == fundCode