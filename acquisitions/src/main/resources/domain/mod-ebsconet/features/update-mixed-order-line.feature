@parallel=false
Feature: Update Ebsconet Order Line

  Background:
    * url baseUrl

#    * callonce dev {tenant: 'test_ebsconet'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables
  @parallel=false
  Scenario Outline: Update P/E Mix line with new quantity

    * def orderId = <ebsconetQuantity>
    * def currentPQuantity = <currentPQuantity>
    * def currentEQuantity = <currentEQuantity>
    * def expectedPQuantity = <expectedPQuantity>
    * def expectedEQuantity = <expectedEQuantity>
    ## prepare compositePurchaseOrder
    Given path '/orders/composite-orders'
    And request
    """
    {
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      compositePoLines: [{
        acquisitionMethod: 'Approval Plan',
        cost: {
          listUnitPrice: 2.0,
          listUnitPriceElectronic: 2.0,
          currency: 'USD',
          quantityPhysical: #(currentPQuantity),
          quantityElectronic: #(currentPQuantity)
        },
        locations: [
          {
            locationId: '#(globalLocationsId)',
            quantity: 2,
            quantityPhysical: #(currentPQuantity),
            quantityElectronic: #(currentPQuantity)
          }
        ],
        orderFormat: 'P/E Mix',
        source: 'User',
        titleOrPackage: 'test'
      }]
    }
    """
    When method POST
    Then status 201
    * def poLineNumber = $.compositePoLines[0].poLineNumber
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
    * set ebsconetLine.subscriptionToDate = "2021-10-09T00:00:00.000+00:00"
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
    And request
    When method GET
    Then status 200
    And match $.compositePoLines[0].cost.quantityPhysical == expectedPQuantity
    And match $.compositePoLines[0].cost.quantityElectronic == expectedEQuantity
    And match $.compositePoLines[0].locations[0].quantityPhysical == expectedPQuantity
    And match $.compositePoLines[0].locations[0].quantityElectronic == expectedEQuantity



    Examples:
      | ebsconetQuantity | currentPQuantity | currentEQuantity | expectedPQuantity | expectedEQuantity  |
      | 7                | 1                | 3                | 1                 | 6                  |
     # | 9                | 4                | 7                | 5                 | 4                  |
    #  | 9                | 1                | 1                | 5                 | 4                  |
   #   | 7                | 3                | 1                | 6                 | 1                  |

 ## Scenario Outline: Update P/E Mix line with new price
 ##   Examples:
 ##     | ebsconetPrice | currentPPrice | currentEPrice | expectedPrice | expectedEPrice  |
 ##     | 7             | 1             | 3             | 1             | 6               |
 ##     | 9             | 4             | 7             | 5             | 4               |
 ##     | 9             | 1             | 1             | 5             | 4               |
 ##     | 7             | 3             | 1             | 6             | 1               |
