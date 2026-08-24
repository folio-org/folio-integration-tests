Feature: Create order line
  # parameters: orderId, title

  Background:
    * url baseUrl

  Scenario: Create order line
    Given path 'orders/order-lines'
    And headers headersUser
    And request
    """
        {
          "titleOrPackage": "#(title)",
          "orderFormat": "Physical Resource",
          "purchaseOrderId": "#(orderId)",
          "source": "User",
          "cost": {
            "currency": "USD",
            "discountType": "percentage",
            "quantityPhysical": 1,
            "listUnitPrice": "20"
          },
          "details": {
            "productIds": [
            ]
          },
          "physical": {
            "createInventory": "Instance, Holding, Item",
            "materialType": "1a54b431-2e4f-452d-9cae-9cee66c9a892"
          },
          "locations": [
            {
              "locationId": "53cf956f-c1df-410b-8bea-27f712cca7c0",
              "quantityPhysical": 1
            }
          ],
          "vendorDetail": {
            "instructions": "",
            "vendorAccount": "99999-10",
            "referenceNumbers": [
              {
                "refNumber": "3123621786817",
                "refNumberType": "Vendor order reference number"
              }
            ]
          },
          "acquisitionMethod": "306489dd-0053-49ee-a068-c316444a8f55",
          "isPackage": false,
          "checkinItems": false,
          "automaticExport": false
        }
        """
    When method POST
    Then status 201
