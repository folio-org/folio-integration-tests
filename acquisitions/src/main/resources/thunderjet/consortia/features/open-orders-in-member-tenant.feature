# For MODORDERS-1310
@parallel=false
Feature: Open orders in member tenant, share instance in one case

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }
    * call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': '*/*' }
    * configure headers = headersUni

    * configure retry = { interval: 5000, count: 5 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fiscalYearId = callonce uuid
    * def ledgerId = callonce uuid
    * def fundId = callonce uuid
    * def budgetId = callonce uuid
    * def vendorId = callonce uuid

    * def currentYear = call getCurrentYear
    * def codePrefix = call random_string
    * def code = codePrefix + currentYear
    * def periodStart = currentYear + '-01-01T00:00:00Z'
    * def periodEnd = currentYear + '-12-30T23:59:59Z'

    * def v = callonce createFiscalYear { id: '#(fiscalYearId)', code: '#(code)', periodStart: '#(periodStart)', periodEnd: '#(periodEnd)' }
    * def v = callonce createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * def v = callonce createOrganization { id: '#(vendorId)', name: 'University Vendor', code: 'UV', isVendor: true, status: 'Active' }

    # Enable instance matching in member tenant
    * def v = callonce enableInstanceMatching

    # Every line below is called by each test cleanly
    * def orderId = call uuid
    * def poLineId = call uuid

    * def orderLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.fundDistribution[0].fundId = fundId
    * set orderLine.fundDistribution[0].code = fundId
    * set orderLine.locations[0].tenantId = universityTenantName
    * set orderLine.locations[0].locationId = universityLocationsId
    * set orderLine.locations[1].tenantId = universityTenantName
    * set orderLine.locations[1].locationId = universityLocationsId2
    * remove orderLine.locations[2]
    * set orderLine.cost.quantityPhysical = 2
    * set orderLine.cost.poLineEstimatedPrice = 2.0
    * def productId = { productId: '12345', productIdType: '#(globalISBNIdentifierTypeId)' }
    * set orderLine.details.productIds = [ '#(productId)' ]
    * set orderLine.physical.materialSupplier = vendorId
    * set orderLine.eresource.accessProvider = vendorId

  @Positive
  Scenario: Create and open an order in university tenant (with a central instance)
    # 1. Create an instance in central tenant
    * configure headers = headersCentral
    * def instanceId = call uuid
    * def identifiers = [ { value: '12345', identifierTypeId: '#(globalISBNIdentifierTypeId)' } ]
    * def v = call createInstance { id: '#(instanceId)', title: 'instance title', instanceTypeId: '#(globalInstanceTypeId)', identifiers: '#(identifiers)' }

    # 2. Create and open order in university tenant (using a matching productId)
    * configure headers = headersUni
    * def v = call createOrder { id: '#(orderId)', vendor: '#(vendorId)' }

    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Verify shadow instance, holdings and items in university tenant
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == instanceId

    Given path 'inventory/instances', instanceId
    Then retry until responseStatus == 200
    When method GET

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    Then retry until responseStatus == 200
    And retry until response.totalRecords == 2
    When method GET

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    Then retry until responseStatus == 200
    And retry until response.totalRecords == 2
    When method GET

    # 4. Unopen order with delete holdings
    * def v = call unopenOrderDeleteHoldings { "orderId": "#(orderId)" }

    # 5. Delete instance to avoid the instance being used by the next test
    * configure headers = headersCentral
    * def v = call deleteInstance { "id": "#(instanceId)" }

  @Positive
  Scenario: Create and open an order in university tenant (with no central instance)
    # 1. Create and open order in university tenant
    * def v = call createOrder { id: '#(orderId)', vendor: '#(vendorId)' }

    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get the instance id
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    * def poLineInstanceId = $.instanceId

    # 3. Verify instance, holdings and items in university tenant
    Given path 'inventory/instances', poLineInstanceId
    When method GET
    Then status 200

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    # 4. Verify nothing was created in the central tenant
    * configure headers = headersCentral
    Given path 'inventory/instances', poLineInstanceId
    Then retry until responseStatus == 404
    When method GET

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + poLineInstanceId
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 0
    When method GET
    Then status 200