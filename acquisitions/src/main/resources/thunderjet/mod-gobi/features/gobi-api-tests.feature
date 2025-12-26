Feature: GOBI api tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }

    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, application/xml', 'x-okapi-tenant': '#(testTenant)' }

    * def locationId1 = call uuid
    * def locationId2 = call uuid
    * def locationId3 = call uuid
    * def locationId4 = call uuid

  Scenario: Validate get user and post user
    Given path '/gobi/validate'
    And headers headers
    When method GET
    Then status 200
    And match /test == 'GET - OK'

    Given path '/gobi/validate'
    And headers headers
    When method POST
    Then status 200
    And match /test == 'POST - OK'

  Scenario: Created an order and Checked fields of the order to match with requested data
    * def sample_po_2 = read('classpath:samples/mod-gobi/po-listed-electronic-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

    # checked order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # matched order lines requested and stored information
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == true
    And match $.poLines[0].contributors[0].contributor == 'ANDERSON, KENNETH, 1956-'
    And match $.poLines[0].cost.listUnitPriceElectronic == 14.95
    And match $.poLines[0].cost.poLineEstimatedPrice == 14.95
    And match $.poLines[0].cost.currency == 'USD'
    And match $.poLines[0].details.productIds[0].productId == '9780817913465'
    And match $.poLines[0].details.productIds[0].qualifier == '(electronic bk.)'
    And match $.poLines[0].orderFormat == 'Electronic Resource'
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].publisher == 'HOOVER INSTITUTION PRESS,'
    And match $.poLines[0].publicationDate == '2012.'
    And match $.poLines[0].receiptStatus == 'Receipt Not Required'
    And match $.poLines[0].titleOrPackage == 'LIVING WITH THE UN[electronic resource] :AMERICAN RESPONSIBILITIES AND INTERNATIONAL ORDER.'
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99952919209'

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  # For MODGOBI-195
  Scenario: Try to create an order with invalid custom mapping and check error response
    # post invalid UnlistedPrintMonograph
    * def invalid_mapping = read('classpath:samples/mod-gobi/invalid-mappings/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request invalid_mapping
    When method POST
    Then status 201

    # try to create an order using the mapping above
    * def sample_po_3 = read('classpath:samples/mod-gobi/po-unlisted-print-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_3
    When method POST
    Then status 500
    And match responseHeaders['Content-Type'][0] == 'application/xml'

    # delete old UnlistedPrintMonograph
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

  Scenario: Try to send invalid requests and check responses
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-serial.json')
    * def invalid_mapping_type = read('classpath:samples/mod-gobi/invalid-mappings/unlisted-print-serial-custom.json')
    * def invalid_mapping_field = read('classpath:samples/mod-gobi/invalid-mappings/unlisted-print-serial-2.json')
    * def invalid_mapping_translation = read('classpath:samples/mod-gobi/invalid-mappings/unlisted-print-serial-1.json')

    # add mapping configuration with invalid order type
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request invalid_mapping_type
    When method POST
    Then status 400

    # verify the new mapping changes were not applied
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 404

    # add mapping configuration with invalid field name
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request invalid_mapping_field
    When method POST
    Then status 400

    # verify the new mapping changes were not applied
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 404

    # add mapping configuration with invalid translation
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request invalid_mapping_translation
    When method POST
    Then status 400

    # verify the new mapping changes were not applied
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 404

  Scenario: Make sure API methods behave correctly in different situations
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-serial.json')

    # Verify original mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Default'
    And match response.orderMappings.orderType == 'UnlistedPrintSerial'
    And match response.orderMappings.mappings[1].dataSource.default == "true"
    And match response.orderMappings.mappings[2].dataSource.default == "#notpresent"

    # Delete non-existent custom mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 404

    # Update non-existent custom mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method PUT
    Then status 404

    # Create custom mapping
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # Re-create already created custom mapping
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 409

    # Verify the newly added mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Custom'
    And match response.orderMappings.orderType == 'UnlistedPrintSerial'
    And match response.orderMappings.mappings[1].dataSource.default == "false"
    And match response.orderMappings.mappings[2].dataSource.default == "true"

    # Update existing custom mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method PUT
    Then status 204

    # Delete existing custom mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # Verify original mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Default'
    And match response.orderMappings.orderType == 'UnlistedPrintSerial'
    And match response.orderMappings.mappings[1].dataSource.default == "true"
    And match response.orderMappings.mappings[2].dataSource.default == "#notpresent"


  Scenario: Make sure updated mapping is applied whenever placing orders
    * def sample_po_original = read('classpath:samples/mod-gobi/po-unlisted-print-serial.xml')
    * def sample_po_updated = read('classpath:samples/mod-gobi/po-unlisted-print-serial-updated.xml')

    # Put an order for original mapping
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_original
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Check order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    And def orderId1 = response.purchaseOrders[0].id

    # Verify order line data
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99974828469'

    # Update mapping
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-serial.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # Try to put an order for original mapping
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_original
    When method POST
    Then status 500
    And match response == 'Cannot invoke "org.folio.rest.acq.model.PoLine$OrderFormat.equals(Object)" because the return value of "org.folio.rest.acq.model.PoLine.getOrderFormat()" is null'

    # Put order for updated mapping
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_updated
    When method POST
    Then status 201
    * def poLineNumberUpdated = /Response/PoLineNumber

    # Check order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumberUpdated.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == false
    * def orderId2 = response.purchaseOrders[0].id

    # Verify order line data
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumberUpdated + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99974828470'

    # Delete new mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId1)" }
    * def v = call cleanupOrderData { orderId: "#(orderId2)" }

  Scenario: Verify order fields after successful mapping update
    # Update mapping
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-serial.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # Put an order for updated mapping
    * def sample_po_updated = read('classpath:samples/mod-gobi/po-unlisted-print-serial-updated.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po_updated
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Check order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == false
    * def orderId = response.purchaseOrders[0].id

    # Verify order line data
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == false
    And match $.poLines[0].cost.listUnitPrice == 0.0
    And match $.poLines[0].cost.poLineEstimatedPrice == 0.0
    And match $.poLines[0].cost.currency == 'USD'
    And match $.poLines[0].orderFormat == 'Physical Resource'
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].titleOrPackage == 'Lightspeed Magazine'
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99974828470'

    # Delete new mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  Scenario: Verify the lookup service integration endpoints work correctly
    # Update mapping
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # Put an order for available lookup translations
    * def sample_po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # Check order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true
    * def orderId = response.purchaseOrders[0].id

    # Verify order line data
    # New order is not created, as one already exists
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == false
    And match $.poLines[0].cost.listUnitPrice == 1.0
    And match $.poLines[0].cost.poLineEstimatedPrice == 1.0
    And match $.poLines[0].cost.currency == 'USD'
    And match $.poLines[0].details.receivingNote == 'pref'
    And match $.poLines[0].fundDistribution[0].code == 'USHIST'
    And match $.poLines[0].fundDistribution[0].distributionType == 'percentage'
    And match $.poLines[0].fundDistribution[0].value == 100.0
    And match $.poLines[0].orderFormat == 'Physical Resource'
    And match $.poLines[0].poLineNumber == poLineNumber
    And match $.poLines[0].requester == 'GOBI'
    And match $.poLines[0].receiptStatus == 'Awaiting Receipt'
    And match $.poLines[0].titleOrPackage == 'Lightspeed Magazine'
    And match $.poLines[0].tags.tagList[0] == 'po_6733180275-1'
    And match $.poLines[0].vendorDetail.vendorAccount == '891080'
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99974828479'

    # Delete new mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # Cleanup order data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

  Scenario: Verify that fetching all mappings include custom ones
    # Verify all mappings are default at first
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.orderMappingsViews[0].mappingType == 'Default'
    And match response.orderMappingsViews[1].mappingType == 'Default'
    And match response.orderMappingsViews[2].mappingType == 'Default'
    And match response.orderMappingsViews[3].mappingType == 'Default'
    And match response.orderMappingsViews[4].mappingType == 'Default'
    And match response.orderMappingsViews[4].orderMappings.mappings[2].field == 'COLLECTION'
    And match response.orderMappingsViews[5].mappingType == 'Default'
    And match response.orderMappingsViews[5].orderMappings.mappings[2].field == 'CLAIM_ACTIVE'

    # Update mappings
    * def valid_mapping_1 = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping_1
    When method POST
    Then status 201

    * def valid_mapping_2 = read('classpath:samples/mod-gobi/unlisted-print-serial.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping_2
    When method POST
    Then status 201

    # Verify custom mappings
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.orderMappingsViews[0].mappingType == 'Default'
    And match response.orderMappingsViews[1].mappingType == 'Default'
    And match response.orderMappingsViews[2].mappingType == 'Default'
    And match response.orderMappingsViews[3].mappingType == 'Default'
    And match response.orderMappingsViews[4].mappingType == 'Custom'
    And match response.orderMappingsViews[4].orderMappings.mappings[2].field == 'COLLECTION'
    And match response.orderMappingsViews[5].mappingType == 'Custom'
    And match response.orderMappingsViews[5].orderMappings.mappings[2].field == 'COLLECTION'

    # Delete new mappings
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    Given path '/gobi/orders/custom-mappings/UnlistedPrintSerial'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200