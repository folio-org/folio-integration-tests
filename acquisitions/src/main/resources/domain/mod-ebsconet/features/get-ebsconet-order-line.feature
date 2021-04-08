Feature: Get Ebsconet Order Line

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderId = call uuid
    * def poLineId = call uuid

  Scenario: Create minimal order, get matching Ebsconet Line
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      compositePoLines: [{
        acquisitionMethod: 'Approval Plan',
        cost: {
          listUnitPrice: 2.0,
          currency: 'USD',
          quantityPhysical: 1
        },
        locations: [
          {
            locationId: '#(globalLocationsId)',
            quantity: 1,
            quantityPhysical: 1
          }
        ],
        orderFormat: 'Physical Resource',
        source: 'User',
        titleOrPackage: 'test'
      }]
    }
    """
    When method POST
    Then status 201
    * def poLineNumber = $.compositePoLines[0].poLineNumber

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    And match $ == { vendor: "testcode", unitPrice: 2.0, currency: "USD", poLineNumber: "#(poLineNumber)", quantity: 1, workflowStatus: "Pending" }

  Scenario: Create order with more information, get matching Ebsconet Line
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cancellationRestriction = false
    * set orderLine.cancellationRestrictionNote = "Note"
    * set orderLine.details.subscriptionFrom = '2018-10-09T00:00:00.000Z'
    * set orderLine.details.subscriptionInterval = 824
    * set orderLine.details.subscriptionTo = '2020-10-09T00:00:00.000Z'
    * set orderLine.vendorDetail.referenceNumbers = [ { refNumber: "123456-78", refNumberType: "Vendor title number", vendorDetailsSource: "OrderLine" } ]
    * set orderLine.fundDistribution[0].code = "TST-FND"
    * set orderLine.publisher = "MIT Press"
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      compositePoLines: [#(orderLine)]
    }
    """
    When method POST
    Then status 201
    * def poLineNumber = $.compositePoLines[0].poLineNumber

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    And match $ == { vendor: "testcode", cancellationRestriction: false, cancellationRestrictionNote: "Note", unitPrice: 1.0, currency: "USD", vendorReferenceNumbers: [{ refNumber: "123456-78", refNumberType: "Vendor title number" }], poLineNumber: "#(poLineNumber)", subscriptionToDate: "2020-10-09T00:00:00.000Z", subscriptionFromDate: "2018-10-09T00:00:00.000Z", quantity: 1, fundCode: "TST-FND", publisherName: "MIT Press", vendorAccountNumber: "1234", workflowStatus: "Pending" }

