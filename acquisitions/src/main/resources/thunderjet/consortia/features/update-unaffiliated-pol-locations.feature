Feature: Update PoLine locations with tenantIds the user do not have affiliations with

  Background:
    * url baseUrl
    * call login centralUser1
    * def headersUser = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid
    * def orderId = callonce uuid
    * def poLineId = callonce uuid

    * table poLineLocations
      | locationId             | quantity | quantityPhysical | tenantId           |
      | centralLocationsId     | 1        | 1                | centralTenantId    |
      | centralLocationsId2    | 1        | 1                | centralTenantId    |
      | universityLocationsId  | 1        | 1                | universityTenantId |
      | universityLocationsId2 | 1        | 1                | universityTenantId |
    * callonce createOrder { id: '#(orderId)' }
    * callonce createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', quantity: 4, locations: '#(poLineLocations)', isPackage: True }

    * def orderLineResponse = call getOrderLine { poLineId: '#(poLineId)' }
    * def poLine = orderLineResponse.response

  Scenario: Modify unaffiliated location quantity
    # Update PoLine locations with centralLocationsId2 and universityLocationsId
    * def poLine = originalPoLine
    * set poLine.locations[1].quantityPhysical = 2
    * set poLine.locations[2].quantityPhysical = 2
    * set poLine.cost.quantityPhysical = 6
    Given path 'orders/order-lines/', poLineId
    And request poLine
    When method PUT
    Then status 422
    And match response.errors[0].code == "locationUpdateWithoutAffiliation"
    
    
  Scenario: Modify unaffiliated location quantity
    # Update PoLine locations with universityLocationsId2 removed
    * set poLine.locations = karate.filter(poLine.locations, (loc) => loc.locationId != universityLocationsId)
    * set poLine.cost.quantityPhysical = 3
    Given path 'orders/order-lines/', poLineId
    And request poLine
    When method PUT
    Then status 422
    And match response.errors[0].code == "locationUpdateWithoutAffiliation"

    
  Scenario: Modify unaffiliated location quantity
    # Update PoLine locations with changes only to centralLocationsId and centralLocationsId2
    * set poLine.locations = karate.filter(poLine.locations, (loc) => loc.locationId != centralLocationsId2)
    * set poLine.locations[0].quantityPhysical = 3
    * set poLine.cost.quantityPhysical = 5
    Given path 'orders/order-lines/', poLineId
    And request poLine
    When method PUT
    Then status 204