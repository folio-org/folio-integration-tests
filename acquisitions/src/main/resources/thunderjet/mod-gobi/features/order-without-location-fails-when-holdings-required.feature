# For MODGOBI-233, https://foliotest.testrail.io/index.php?/cases/view/852052
Feature: Order without location fails when Inventory interaction requires holdings

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    # Set Electronic Default To Require Holdings So Missing Location Triggers The Validation Error
    * def v = call read('classpath:thunderjet/mod-orders/reusable/set-create-inventory.feature') { eresource: 'Instance, Holding', physical: 'Instance, Holding, Item', other: 'None' }

    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * def po = read('classpath:samples/mod-gobi/po-listed-electronic-monograph-no-location.xml')

    # Ensure Custom Mapping Is Removed Even If The Scenario Fails Mid-Way
    * configure afterScenario =
    """
    function() {
      karate.call('classpath:thunderjet/mod-gobi/reusable/delete-custom-mapping.feature', { orderType: 'ListedElectronicMonograph' });
    }
    """

  @C852052
  @Negative
  Scenario: Listed Electronic Monograph Order Without Location Fails With Quantity Mismatch
    # 1. Fetch The Default ListedElectronicMonograph Mapping
    Given path '/gobi/orders/custom-mappings/ListedElectronicMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    * def orderMappings = response.orderMappings

    # 2. Remove The LOCATION Field From The Mapping (Simulates Clearing The Location Accordion In Settings)
    * def withoutLocation = karate.filter(orderMappings.mappings, function(m){ return m.field != 'LOCATION' })
    * set orderMappings.mappings = withoutLocation

    # 3. Save The Mapping As A Custom Mapping
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request orderMappings
    When method POST
    Then status 201

    # 4. Submit A GOBI Order And Expect Failure Due To Missing Location With Holdings-Required Default
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-bypass-cache': 'true' }
    And request po
    When method POST
    Then status 422
    And match /Response/Error/Code == 'electronicLocCostQtyMismatch'
    And match /Response/Error/Message == 'PO Line electronic quantity and Locations electronic quantity do not match'

    # 5. Verify No Order Was Created For This YBPOrderKey
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poLine.vendorDetail.referenceNumbers=="*901022691786*"'
    When method GET
    Then status 200
    And match response.totalRecords == 0