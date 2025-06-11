# MODORDERS-1310
Feature: Open orders in member tenant, share instance in one case

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * def headersUniUser = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * configure headers = headersUniUser

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity


  Scenario: Create and open an order in university tenant, no central instance
    * def orderId = call uuid
    * def poLineId = call uuid

    # Create and open order in university tenant
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)' }

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    * def productId = { productId: '12345', productIdType: '#(globalISBNIdentifierTypeId)' }
    * set orderLine.details.productIds = [ productId ]
    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    * def v = call openOrder { orderId: '#(orderId)' }

    # Get the instance id
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # Verify instance, holdings and items in university tenant
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

    # Verify nothing was created in the central tenant
    * configure headers = headersCentral
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 404

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0


  Scenario: Create and open an order in university tenant, with a central instance
    # Create an instance in central tenant
    * def instanceId = call uuid
    * configure headers = headersCentral
    * def identifiers = [ { value: '12345', identifierTypeId: '#(globalISBNIdentifierTypeId)' } ]
    * def v = call createInstance { id: instanceId, title: 'instance title', instanceTypeId: '#(globalInstanceTypeId)', identifiers: '#(identifiers)' }

    # Create and open order in university tenant (using a matching productId)
    * configure headers = headersUniUser
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)' }

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.locations[2].tenantId = universityTenantName
    * set orderLine.locations[2].locationId = universityLocationsId
    * def productId = { productId: '12345', productIdType: '#(globalISBNIdentifierTypeId)' }
    * set orderLine.details.productIds = [ productId ]
    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    * def v = call openOrder { orderId: '#(orderId)' }

    # Verify shadow instance, holdings and items in university tenant
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2
