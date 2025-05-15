Feature: Update PoLine locations with tenantIds the user do not have affiliations with

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def resultAdmin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def okapitoken = resultAdmin.okapitoken
    * def resultUser = call eurekaLogin { username: '#(centralUser.username)', password: '#(centralUser.password)', tenant: '#(centralTenantName)' }
    * def okapitokenUser = resultUser.okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * configure headers = headersCentral

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid
    * def orderId = callonce uuid
    * def poLineId = callonce uuid

    * table poLineLocations
      | locationId             | quantity | quantityPhysical | tenantId             |
      | centralLocationsId     | 1        | 1                | centralTenantName    |
      | centralLocationsId2    | 1        | 1                | centralTenantName    |
      | universityLocationsId  | 1        | 1                | universityTenantName |
      | universityLocationsId2 | 1        | 1                | universityTenantName |
    * callonce createOrder { id: '#(orderId)' }
    * callonce createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', quantity: 4, locations: '#(poLineLocations)', isPackage: True }

    * configure headers = headersUser
    * def orderLineResponse = call getOrderLine { poLineId: '#(poLineId)' }
    * def poLine = orderLineResponse.response


  Scenario: Modify unaffiliated locations
    # Update PoLine locations with centralLocationsId2 and universityLocationsId
    * set poLine.locations[1].quantityPhysical = 2
    * set poLine.locations[2].quantityPhysical = 2
    * set poLine.cost.quantityPhysical = 6
    Given path 'orders/order-lines/', poLineId
    And request poLine
    When method PUT
    Then status 422
    And match response.errors[0].code == "locationUpdateWithoutAffiliation"


  Scenario: Remove unaffiliated location
    # Update PoLine locations with universityLocationsId2 removed
    * set poLine.locations = karate.filter(poLine.locations, (loc) => loc.locationId != universityLocationsId)
    * set poLine.cost.quantityPhysical = 3
    Given path 'orders/order-lines/', poLineId
    And request poLine
    When method PUT
    Then status 422
    And match response.errors[0].code == "locationUpdateWithoutAffiliation"