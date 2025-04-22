# MODORDERS-180, MODORDERS-181, MODORDERS-1098
Feature: Check estimated price with composite order

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken
    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser
    * call variables


  Scenario: Check estimated price with composite order
    * print '## Prepare finances'
    * configure headers = headersAdmin
    * def histFundId = call uuid
    * def genrlFundId = call uuid
    * def miscHistFundId = call uuid
    * def histBudgetId = call uuid
    * def genrlBudgetId = call uuid
    * def miscHistBudgetId = call uuid
    * def v = call createFund { id: "#(histFundId)" }
    * def v = call createBudget { id: "#(histBudgetId)", fundId: "#(histFundId)", allocated: 1000 }
    * def v = call createFund { id: "#(genrlFundId)" }
    * def v = call createBudget { id: "#(genrlBudgetId)", fundId: "#(genrlFundId)", allocated: 1000 }
    * def v = call createFund { id: "#(miscHistFundId)" }
    * def v = call createBudget { id: "#(miscHistBudgetId)", fundId: "#(miscHistFundId)", allocated: 1000 }
    * configure headers = headersUser

    * print '## Prepare the order'
    * def po = read('classpath:samples/mod-orders/compositeOrders/po-listed-print-monograph.json')
    # Make sure expected number of PO Lines available
    * assert po.poLines.length == 2
    * assert po.poLines[0].orderFormat == "P/E Mix"
    * assert po.poLines[1].orderFormat == "Electronic Resource"
    # Set the fund ids
    * set po.poLines[0].fundDistribution[0].fundId = histFundId
    * set po.poLines[0].fundDistribution[1].fundId = genrlFundId
    * set po.poLines[1].fundDistribution[0].fundId = miscHistFundId

    # Prepare cost details for the first PO Line (see MODORDERS-180 and MODORDERS-181)
    * def cost = po.poLines[0].cost
    * set cost.additionalCost = 10.0
    * set cost.discount = 3.0
    * set cost.discountType = "percentage"
    * set cost.quantityElectronic = 1
    * set cost.listUnitPriceElectronic = 5.5
    * set cost.quantityPhysical = 3
    * set cost.listUnitPrice = 9.99
    * set cost.poLineEstimatedPrice = null
    * def expectedTotalPoLine1 = 44.41

    # Prepare cost details for the second PO Line (see MODORDERS-180 and MODORDERS-181)
    * def cost = po.poLines[1].cost
    * set cost.additionalCost = 2
    * set cost.discount = 4.99
    * set cost.discountType = "amount"
    * set cost.quantityElectronic = 3
    * set cost.listUnitPriceElectronic = 11.99
    * set cost.poLineEstimatedPrice = null
    * def expectedTotalPoLine2 = 32.98

    * print '## Create the composite order'
    Given path 'orders/composite-orders'
    And request po
    When method POST
    Then status 201

    * print '## Check the returned composite order'
    # Order
    * match $.id == '#notnull'
    * def orderId = $.id
    * match $.poNumber == '#notnull'
    * match $.poLines == '#[2]'
    * match $.workflowStatus == "Pending"
    # Lines
    * def poLineId1 = response.poLines[0].id
    * def poLineId2 = response.poLines[1].id
    * match each $.poLines[*].purchaseOrderId == orderId
    * match $.poLines[*].id == ['#notnull', '#notnull']
    * match each $.poLines[*].poLineNumber == '#? _.startsWith("' + response.poNumber + '")'
    * match $.poLines[*].instanceId == []
    * match each $.poLines[0].locations == '#? _.quantityPhysical + _.quantityElectronic == _.quantity'
    * match each $.poLines[1].locations == '#? _.quantityElectronic == _.quantity'

    # see MODORDERS-180 and MODORDERS-181
    * match $.poLines[0].cost.poLineEstimatedPrice == expectedTotalPoLine1
    * match $.poLines[1].cost.poLineEstimatedPrice == expectedTotalPoLine2
    # the sum would be wrong with a simple addition: 44.41 + 32.98 results in 77.38999999999999
    * match $.totalEstimatedPrice == (expectedTotalPoLine1 * 100 + expectedTotalPoLine2 * 100) / 100

    * print '## Check created order lines'
    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.poLines == '#[2]'
    * def poLine1 = karate.jsonPath(response, "$.poLines[?(@.id=='" + poLineId1 + "')]")[0]
    * def poLine2 = karate.jsonPath(response, "$.poLines[?(@.id=='" + poLineId2 + "')]")[0]
    * match poLine1.cost.poLineEstimatedPrice == expectedTotalPoLine1
    * match poLine2.cost.poLineEstimatedPrice == expectedTotalPoLine2

    * print '## Check created encumbrances'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0
