Feature: Update Ebsconet Order Line

  Background:
    * url baseUrl

    #* callonce dev {tenant: 'testebsconet6'}
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
        acquisitionMethod: '#(globalPurchaseAcqMethodId)',
        cost: {
          listUnitPriceElectronic: 2.0,
          currency: 'USD',
          quantityElectronic: 1
        },
        orderFormat: 'Electronic Resource',
        eresource: {
          activated: false,
          activationDue: 1,
          createInventory: 'None',
          trial: false,
          accessProvider: '#(globalVendorId)'
        },
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
    * set orderLine.details.subscriptionFrom = '2018-10-09T00:00:00.000+00:00'
    * set orderLine.details.subscriptionInterval = 824
    * set orderLine.details.subscriptionTo = '2020-10-09T00:00:00.000+00:00'
    * set orderLine.vendorDetail.referenceNumbers = [ { refNumber: "123456-78", refNumberType: "Vendor title number", vendorDetailsSource: "OrderLine" } ]
    * set orderLine.fundDistribution[0].code = "TST-FND"
    * set orderLine.renewalNote = "Renewal Note"

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
    And match $ == { vendor: "testcode", cancellationRestriction: false, cancellationRestrictionNote: "Note", unitPrice: 1.0, currency: "USD", vendorReferenceNumbers: [{ refNumber: "123456-78", refNumberType: "Vendor title number" }], poLineNumber: "#(poLineNumber)", internalNote: "Renewal Note", subscriptionToDate: "2020-10-09T00:00:00.000+00:00", subscriptionFromDate: "2018-10-09T00:00:00.000+00:00", quantity: 1, fundCode: "TST-FND", vendorAccountNumber: "1234", workflowStatus: "Pending" }
    * def ebsconetLine = response
    * set ebsconetLine.unitPrice = 3.0
    * set ebsconetLine.currency = "EUR"
    * set ebsconetLine.quantity = 2
    * set ebsconetLine.vendorAccountNumber = "12345"
    * set ebsconetLine.vendorReferenceNumbers[0].refNumber = "123456-77"
    * set ebsconetLine.cancellationRestriction = true
    * set ebsconetLine.cancellationRestrictionNote = "Note1"
    * set ebsconetLine.subscriptionToDate = "2022-10-09T00:00:00.000+00:00"
    * set ebsconetLine.subscriptionFromDate = "2019-10-09T00:00:00.000+00:00"
    * set ebsconetLine.publisherName = "Test"
    * set ebsconetLine.fundCode = "TST-FND-3"
    ## set read only fields
    * set ebsconetLine.workflowStatus = "Open"
    * set ebsconetLine.vendor = "shouldn't update"
    * set ebsconetLine.internalNote = "Renewal Note1"


    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 204

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    And match $ ==
    """
    {
      vendor: "testcode",
      cancellationRestriction: true,
      cancellationRestrictionNote: "Note1",
      unitPrice: 3.0,
      currency: "EUR",
      vendorReferenceNumbers: [
        {
          refNumber: "123456-77",
          refNumberType: "Vendor title number"
        }
      ],
      poLineNumber: "#(poLineNumber)",
      subscriptionToDate: "2022-10-09T00:00:00.000+00:00",
      subscriptionFromDate: "2019-10-09T00:00:00.000+00:00",
      quantity: 2,
      fundCode: "TST-FND-3",
      publisherName: "Test",
      vendorAccountNumber: "12345",
      workflowStatus: "Pending",
      internalNote: "Renewal Note1"
    }
    """


