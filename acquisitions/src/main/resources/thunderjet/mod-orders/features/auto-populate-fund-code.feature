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

  Scenario: Create order with PO line fund distribution missing fundCode, expect it to be auto-populated
    # Generate unique IDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def codePrefix = call random_string
    * def fundCode = 'FC-' + codePrefix

    # Create finance data with admin headers
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # Switch to user headers for order operations
    * configure headers = headersUser

    # Prepare order data using minimal template
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.fundDistribution[0].code

    # Create open order with PO line, fund distribution has fundId but no fundCode
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

    # Retrieve the created PO line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDist = response.fundDistribution[0]

    # Assert that fundCode is automatically populated and matches the fund's code
    * match fundDist.code == fundCode

  Scenario: Create pending order without fundCode, then open order and verify fundCode is populated
    # Generate unique IDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def codePrefix = call random_string
    * def fundCode = 'FC-' + codePrefix

    # Create finance data with admin headers
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # Switch to user headers for order operations
    * configure headers = headersUser

    # Prepare order data using minimal template
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.fundDistribution[0].code

    # Create pending order with PO line, fund distribution has fundId but no fundCode
    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": "#(orderId)",
      "vendor": "#(globalVendorId)",
      "orderType": "One-Time",
      "workflowStatus": "Pending",
      "poLines": [
        #(poLine)
      ]
    }
    """
    When method POST
    Then status 201

    # Verify that fundCode is not populated in pending order
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDistPending = response.fundDistribution[0]
    * match fundDistPending.fundCode == '#notpresent'

    # Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove orderResponse.poLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # Verify that fundCode is now populated after opening the order
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fundDistOpen = response.fundDistribution[0]

    # Assert that fundCode is automatically populated after opening and matches the fund's code
    * match fundDistOpen.code == fundCode
