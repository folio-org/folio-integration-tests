  # MODORDERS-1098
  Feature: Create open composite order

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


    Scenario: Create open composite order and check results
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
      * def line1 = po.compositePoLines[0]
      * def line2 = po.compositePoLines[1]
      * set line1.fundDistribution[0].fundId = histFundId
      * set line1.fundDistribution[1].fundId = genrlFundId
      * set line2.fundDistribution[0].fundId = miscHistFundId
      * set line1.paymentStatus = "Pending"
      * set line1.receiptStatus = "Partially Received"
      * set line2.paymentStatus = "Pending"
      * set line2.receiptStatus = "Partially Received"

      # remove productId from PO line to test scenario when it's not provided so there is no check for existing instance but new one will be created
      * remove line1.details.productIds[0]

      # MODORDERS-117 only physical quantity will be used
      * set line1.orderFormat = "Physical Resource"
      * remove line1.eresource

      # Set locations quantities
      * set line1.locations[1].quantityPhysical = 3
      * set line1.locations[2].quantityPhysical = 7
      * set line1.locations[2].quantityElectronic = 0

      # Set cost quantities
      * set line1.cost.quantityPhysical = 11
      * set line1.cost.quantityElectronic = 0
      * set line1.cost.listUnitPrice = 10.0
      * set line1.cost.listUnitPriceElectronic = 0.0

      # Set status to Open
      * set po.workflowStatus = "Open"

      * print '## Create the composite order'
      Given path 'orders/composite-orders'
      And request po
      When method POST
      Then status 201
      * def po = response

      * print '## Check the returned composite order'
      # Order
      * def getCurrentDateUTC = function() { return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) }
      * match po.dateOrdered contains getCurrentDateUTC()
      * match po.id == '#notnull'
      * match po.poNumber == '#notnull'
      * match po.compositePoLines == '#[2]'
      * match po.workflowStatus == "Open"
      * match po.totalItems == 14
      # Lines
      * def newLines =  po.compositePoLines
      * def poLineId1 = newLines[0].id
      * def poLineId2 = newLines[1].id
      * def orderId = po.id
      * match each newLines[*].purchaseOrderId == orderId
      * match newLines[*].id == '#[2]'
      * match each newLines[*].poLineNumber == '#? _.startsWith("' + po.poNumber + '")'
      * match newLines[*].instanceId == '#[2]'
      * match each newLines[0].locations == '#? _.quantityPhysical + _.quantityElectronic == _.quantity'
      * match each newLines[1].locations == '#? _.quantityElectronic == _.quantity'
      * match newLines[*].locations[*].locationId == []
      * match newLines[*].locations[*].holdingId == '#[5]'

      * print '## Check created order lines'
      Given path 'orders/order-lines'
      And param query = 'purchaseOrderId==' + orderId
      When method GET
      Then status 200
      And match $.poLines == '#[2]'
      * match $.poLines[*].instanceId == ['#notnull', '#notnull']
      * match each $.poLines[*].receiptStatus == 'Partially Received'
      * match each $.poLines[*].paymentStatus == 'Awaiting Payment'

      * print '## Check created instances'
      Given path 'inventory/instances'
      And param query = 'title==("' + line1.titleOrPackage + '" OR "' + line2.titleOrPackage + '")'
      When method GET
      Then status 200
      And match $.totalRecords == 2
      * def instances = response.instances

      * print '## Check created holdings'
      * configure headers = headersAdmin
      Given path 'holdings-storage/holdings'
      And param query = 'instanceId==("' + instances[0].id + '" OR "' + instances[1].id + '")'
      When method GET
      Then status 200
      And match $.totalRecords == 5
      * def holdingIds = $.holdingsRecords[*].id
      * configure headers = headersUser

      * match newLines[*].locations[*].holdingId contains only holdingIds

      * print '## Check created items'
      Given path 'inventory/items'
      And param query = 'purchaseOrderLineIdentifier==("' + newLines[0].id + '" OR "' + newLines[1].id + '")'
      And param limit = 100
      When method GET
      Then status 200
      And match $.totalRecords == 14
      * def itemIds = $.items[*].id

      * print '## Check created pieces'
      Given path 'orders/pieces'
      And param query = 'poLineId==("' + newLines[0].id + '" OR "' + newLines[1].id + '")'
      And param limit = 100
      When method GET
      Then status 200
      * match $.totalRecords == 14
      * match each $.pieces[*].receivingStatus == "Expected"
      * match $.pieces[*].itemId contains only itemIds
      * match $.pieces[*].holdingId == '#[14]'
      * match each $.pieces[*].holdingId  == '#? holdingIds.includes(_)'
      * match $.pieces[*].format == '#[14]'

      * print '## Check created encumbrances'
      Given path 'finance/transactions'
      And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
      When method GET
      Then status 200
      And match $.totalRecords == 3
