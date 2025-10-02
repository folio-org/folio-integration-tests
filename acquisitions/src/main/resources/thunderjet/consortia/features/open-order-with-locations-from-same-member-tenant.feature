# For MODORDERS-1365
Feature: Open order with the same member tenant locations

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * configure headers = headersCentral

    * configure retry = { interval: 10000, count: 5 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = callonce uuid
    * def budgetId = callonce uuid
    * def v = callonce createFund { 'id': '#(fundId)' }
    * def v = callonce createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active' }

    * def orderId = call uuid
    * def poLineId = call uuid

  @Positive
  Scenario: Create and open order with 'Physical' format and locations from the same member tenant
    # 1. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line with the same member tenant locations
    * table poLineLocations
      | locationId             | quantity | quantityPhysical | tenantId             |
      | universityLocationsId  | 1        | 1                | universityTenantName |
      | universityLocationsId2 | 1        | 1                | universityTenantName |
    * table orderLineData
      | id       | orderId | locations       | quantity | quantityElectronic | titleOrPackage | orderFormat         |
      | poLineId | orderId | poLineLocations | 2        | 0                  | 't1'           | 'Physical Resource' |
    * def v = call createOrderLine orderLineData

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

  @Positive
  Scenario: Create and open order with 'Electronic' format and locations from the same member tenant
    # 1. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line with the same member tenant locations
    * table poLineLocations
      | locationId             | quantity | quantityElectronic | tenantId             |
      | universityLocationsId  | 1        | 1                  | universityTenantName |
      | universityLocationsId2 | 1        | 1                  | universityTenantName |
    * table orderLineData
      | id       | orderId | locations       | quantity | quantityElectronic | listUnitPrice | listUnitPriceElectronic | titleOrPackage | orderFormat           |
      | poLineId | orderId | poLineLocations | 0        | 2                  | 0          | 1                       | 't2'           | 'Electronic Resource' |
    * def v = call createOrderLine orderLineData

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

  @Positive
  Scenario: Create and open order with 'P/E Mix' format and locations from the same member tenant
    # 1. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line with the same member tenant locations
    * table poLineLocations
      | locationId             | quantity | quantityPhysical | quantityElectronic | tenantId             |
      | universityLocationsId  | 1        | 1                | 0                  | universityTenantName |
      | universityLocationsId2 | 1        | 0                | 1                  | universityTenantName |
    * table orderLineData
      | id       | orderId | locations       | quantity | quantityElectronic | listUnitPrice | listUnitPriceElectronic | titleOrPackage | orderFormat |
      | poLineId | orderId | poLineLocations | 1        | 1                  | 1             | 1                       | 't3'           | 'P/E Mix'   |
    * def v = call createOrderLine orderLineData

    # 3. Open order
    * def v = call openOrder { orderId: '#(orderId)' }