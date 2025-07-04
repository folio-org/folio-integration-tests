Feature: Update Ebsconet Order Line

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

  Scenario Outline: Update P/E Mix line with new quantity

    * def ebsconetQuantity = <ebsconetQuantity>
    * def currentPQuantity = <currentPQuantity>
    * def currentEQuantity = <currentEQuantity>
    * def expectedPQuantity = <expectedPQuantity>
    * def expectedEQuantity = <expectedEQuantity>

    ## prepare compositePurchaseOrder
    Given path '/orders/composite-orders'
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.cancellationRestriction = false
    * remove orderLine.purchaseOrderId
    * set orderLine.vendorDetail.referenceNumbers = [{ refNumber: "123456-78", refNumberType: "Vendor title number", vendorDetailsSource: "OrderLine" }]
    * set orderLine.fundDistribution[0].code = "TST-FND"
    * set orderLine.publisher = "MIT Press"
    * set orderLine.cost.quantityPhysical = currentPQuantity
    * set orderLine.cost.quantityElectronic = currentEQuantity
    * set orderLine.locations[0].quantityPhysical = currentPQuantity
    * set orderLine.locations[0].quantityElectronic = currentEQuantity
    And request
    """
    {
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      poLines: [#(orderLine)]
    }
    """
    When method POST
    Then status 201
    * def poLineNumber = $.poLines[0].poLineNumber
    * def orderId = $.id

    # get ebsco line
    Given path '/ebsconet/orders/order-lines', poLineNumber
    When method GET
    Then status 200

    * def ebsconetLine = $
    * set ebsconetLine.quantity = ebsconetQuantity
    * set ebsconetLine.fundCode = "TST-FND-3"
    * set ebsconetLine.vendorAccountNumber = "12345"
    * set ebsconetLine.vendorReferenceNumbers[0].refNumber = "123456-77"
    * set ebsconetLine.cancellationRestriction = true
    * set ebsconetLine.cancellationRestrictionNote = "Note1"
    * set ebsconetLine.subscriptionToDate = "2022-10-09T00:00:00.000+00:00"
    * set ebsconetLine.subscriptionFromDate = "2019-10-09T00:00:00.000+00:00"
    * set ebsconetLine.publisherName = "Test"
    * set ebsconetLine.fundCode = "TST-FND-3"

    ## call update ebsco line
    Given path '/ebsconet/orders/order-lines', poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 204

    # check updated prices
    Given path '/orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.poLines[0].cost.quantityPhysical == expectedPQuantity
    And match $.poLines[0].cost.quantityElectronic == expectedEQuantity
    And match $.poLines[0].locations[0].quantityPhysical == expectedPQuantity
    And match $.poLines[0].locations[0].quantityElectronic == expectedEQuantity

    Given path '/orders/composite-orders', orderId
    When method DELETE
    Then status 204

    Examples:
      | ebsconetQuantity | currentPQuantity | currentEQuantity | expectedPQuantity | expectedEQuantity  |
      | 5                | 1                | 3                | 1                 | 4                  |
      | 7                | 4                | 7                | 4                 | 3                  |
      | 9                | 1                | 1                | 5                 | 4                  |
      | 11               | 3                | 1                | 10                | 1                  |
      | 14               | 1                | 1                | 7                 | 7                  |


  Scenario Outline: Update P/E Mix line with new price

    * def ebsconetPrice = <ebsconetPrice>
    * def currentPPrice = <currentPPrice>
    * def currentEPrice = <currentEPrice>
    * def expectedPPrice = <expectedPPrice>
    * def expectedEPrice = <expectedEPrice>

    ## prepare compositePurchaseOrder
    Given path '/orders/composite-orders'
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.cancellationRestriction = false
    * remove orderLine.purchaseOrderId
    * set orderLine.cancellationRestrictionNote = "Note"
    * set orderLine.vendorDetail.referenceNumbers = [{ refNumber: "123456-78", refNumberType: "Vendor title number", vendorDetailsSource: "OrderLine" }]
    * set orderLine.fundDistribution[0].code = "TST-FND"
    * set orderLine.publisher = "MIT Press"
    * set orderLine.cost.listUnitPrice = currentPPrice
    * set orderLine.cost.listUnitPriceElectronic = currentEPrice

    And request
    """
    {
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      poLines: [#(orderLine)]
    }
    """
    When method POST
    Then status 201
    * def poLineNumber = $.poLines[0].poLineNumber
    * def orderId = $.id

    # get ebsco line
    Given path '/ebsconet/orders/order-lines', poLineNumber
    When method GET
    Then status 200

    * def ebsconetLine = $
    * set ebsconetLine.unitPrice = ebsconetPrice
    * set ebsconetLine.fundCode = "TST-FND-3"
    * set ebsconetLine.vendorAccountNumber = "12345"
    * set ebsconetLine.vendorReferenceNumbers[0].refNumber = "123456-77"
    * set ebsconetLine.cancellationRestriction = true
    * set ebsconetLine.cancellationRestrictionNote = "Note1"
    * set ebsconetLine.subscriptionToDate = "2022-10-09T00:00:00.000+00:00"
    * set ebsconetLine.subscriptionFromDate = "2019-10-09T00:00:00.000+00:00"
    * set ebsconetLine.publisherName = "Test"
    * set ebsconetLine.fundCode = "TST-FND-3"

    ## call update ebsco line
    Given path '/ebsconet/orders/order-lines', poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 204

    # check updated prices
    Given path '/orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.poLines[0].cost.listUnitPrice == expectedPPrice
    And match $.poLines[0].cost.listUnitPriceElectronic == expectedEPrice

    Given path '/orders/composite-orders', orderId
    When method DELETE
    Then status 204

    Examples:
      | ebsconetPrice | currentPPrice | currentEPrice | expectedPPrice | expectedEPrice  |
      | 55.00         | 10.00         | 0             | 55.00          | 0               |
      | 66.00         | 40.00         | 25.00         | 33.00          | 33.00           |
      | 77.00         | 0             | 15.00         | 0              | 77.00           |
      | 88.00         | 0             | 0             | 0              | 0               |
