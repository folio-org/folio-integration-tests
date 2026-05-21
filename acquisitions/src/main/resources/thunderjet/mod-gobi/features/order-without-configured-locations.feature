# For MODGOBI-217, MODGOBI-233, https://foliotest.testrail.io/index.php?/cases/view/852048
Feature: Order can be created without configured locations in the system

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    # Set Electronic Default To Instance So Missing Location Does Not Trigger The Quantity Mismatch
    * def v = call read('classpath:thunderjet/mod-orders/reusable/set-create-inventory.feature') { eresource: 'Instance', physical: 'Instance, Holding, Item', other: 'None' }

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

  @C852048
  @Positive
  Scenario: Listed Electronic Monograph Order Is Created When Location Mapping Is Removed
    # 1. Fetch The Default ListedElectronicMonograph Mapping
    Given path '/gobi/orders/custom-mappings/ListedElectronicMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Default'
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

    # 4. Confirm The Custom Mapping Has No LOCATION Field
    Given path '/gobi/orders/custom-mappings/ListedElectronicMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Custom'
    And match each response.orderMappings.mappings[*].field != 'LOCATION'

    # 5. Submit The First GOBI Order While Electronic Default Is Instance
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request po
    When method POST
    Then status 201
    * def poLineNumberInstance = /Response/PoLineNumber

    # 6. Verify The First Composite Order Was Created
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumberInstance.split('-')[0] + '*'
    When method GET
    Then status 200
    * def orderIdInstance = response.purchaseOrders[0].id

    # 7. Verify The First PO Line Has Empty Locations, Instance Inventory, And A Created Instance
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumberInstance + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].orderFormat == 'Electronic Resource'
    And match $.poLines[0].cost.quantityElectronic == 1
    And match $.poLines[0].locations == '#[0]'
    And match $.poLines[0].eresource.createInventory == 'Instance'
    And match $.poLines[0].instanceId == '#notnull'
    * def instanceId = $.poLines[0].instanceId

    # 8. Verify The Instance Was Actually Created In Inventory
    Given path '/instance-storage/instances', instanceId
    And headers headers
    When method GET
    Then status 200

    # 9. Switch Electronic Default To None
    * def v = call read('classpath:thunderjet/mod-orders/reusable/set-create-inventory.feature') { okapitoken: '#(okapitokenAdmin)', eresource: 'None', physical: 'Instance, Holding, Item', other: 'None' }

    # 10. Re-Read The PO XML, Modify YBPOrderKey To A Distinct Value, And Submit The Second GOBI Order
    * def poSecond = read('classpath:samples/mod-gobi/po-listed-electronic-monograph-no-location.xml')
    * set poSecond/PurchaseOrder/Order/ListedElectronicMonograph/OrderDetail/YBPOrderKey = '901022691797'
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request poSecond
    When method POST
    Then status 201
    * def poLineNumberNone = /Response/PoLineNumber

    # 11. Verify The Second Composite Order Was Created
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumberNone.split('-')[0] + '*'
    When method GET
    Then status 200
    * def orderIdNone = response.purchaseOrders[0].id

    # 12. Verify The Second PO Line Has Empty Locations, None Inventory, And Reuses (Does Not Recreate) The Instance
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumberNone + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].orderFormat == 'Electronic Resource'
    And match $.poLines[0].cost.quantityElectronic == 1
    And match $.poLines[0].locations == '#[0]'
    And match $.poLines[0].eresource.createInventory == 'None'
    And match $.poLines[0].instanceId == '#notpresent'

    # 13. Cleanup Both Orders
    * def v = call cleanupOrderData { orderId: "#(orderIdInstance)" }
    * def v = call cleanupOrderData { orderId: "#(orderIdNone)" }
