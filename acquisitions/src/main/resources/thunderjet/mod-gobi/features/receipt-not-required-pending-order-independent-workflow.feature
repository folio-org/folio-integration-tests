# For MODGOBI-208, https://foliotest.testrail.io/index.php?/cases/view/794526
Feature: Receipt not required sets receiving workflow to Independent for Pending order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }

    * callonce login testUser
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * def mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    * def po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph.xml')

    # Ensure Custom Mapping Is Removed Even If The Scenario Fails Mid-Way
    * configure afterScenario =
    """
    function() {
      karate.call('classpath:thunderjet/mod-gobi/reusable/delete-custom-mapping.feature', { orderType: 'UnlistedPrintMonograph' });
    }
    """

  @C794526
  @Positive
  Scenario: Receipt Not Required Forces Independent Receiving Workflow For Pending Order
    # 1. Configure Custom Mapping With Workflow Status Pending And Receipt Status Receipt Not Required
    * set mapping.mappings[16].dataSource.default = "Receipt Not Required"
    * set mapping.mappings[31].dataSource.default = "Pending"
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request mapping
    When method POST
    Then status 201

    # 2. Verify The Custom Mapping Was Applied With Expected Defaults
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method GET
    Then status 200
    And match response.mappingType == 'Custom'
    And match response.orderMappings.mappings[16].dataSource.default == "Receipt Not Required"
    And match response.orderMappings.mappings[31].dataSource.default == "Pending"

    # 3. Submit A GOBI Order Using The Custom Mapping
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # 4. Verify Purchase Order Has Workflow Status Pending And Linked To GOBI Vendor
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].workflowStatus == 'Pending'
    * def orderId = response.purchaseOrders[0].id

    # 5. Verify PO Line Has Receipt Status Receipt Not Required And Independent Receiving Workflow
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].receiptStatus == 'Receipt Not Required'
    And match $.poLines[0].checkinItems == true

    # 6. Cleanup Order Data (Custom Mapping Cleanup Is Handled By afterScenario)
    * def v = call cleanupOrderData { orderId: "#(orderId)" }