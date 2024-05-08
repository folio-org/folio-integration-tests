Feature: Create order
  # parameters: id, vendor?, orderType?, ongoing?, reEncumber?, acqUnitIds?

  Background:
    * url baseUrl

  Scenario: createOrder
    * def vendor = karate.get('vendor', globalVendorId)
    * def orderType = karate.get('orderType', 'One-Time')
    * def ongoing = karate.get('ongoing', null)
    * def reEncumber = karate.get('reEncumber', false)
    * def acqUnitIds = karate.get('acqUnitIds', [])
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: #(id),
      vendor: #(vendor),
      orderType: #(orderType),
      ongoing: #(ongoing),
      reEncumber: #(reEncumber),
      acqUnitIds: #(acqUnitIds)
    }
    """
    When method POST
    Then status 201
