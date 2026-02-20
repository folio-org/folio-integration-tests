  # For MODGOBI-241
Feature: Verify tenant address lookup populates billTo on order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, application/xml', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: Create Tenant Address And Verify GOBI Order BillTo Is Populated
    # 1. Create A Tenant Address With Name Matching LocalData3 Value In The XML Sample
    * def tenantAddress = { name: 'GOBI', address: '10 Estes Street, Ipswich, MA 01938, USA' }
    Given path '/tenant-addresses'
    And headers headersAdmin
    And request tenantAddress
    When method POST
    Then status 201
    * def addressId = response.id

    # 2. Upload Custom Mapping That Includes BILL_TO With LookupConfigAddress Translation
    * def valid_mapping = read('classpath:samples/mod-gobi/unlisted-print-monograph.json')
    Given path '/gobi/orders/custom-mappings'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request valid_mapping
    When method POST
    Then status 201

    # 3. Post A GOBI Order - LocalData3 Contains "GOBI" Which Is Used By LookupConfigAddress
    * def sample_po = read('classpath:samples/mod-gobi/po-unlisted-print-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    And request sample_po
    When method POST
    Then status 201
    * def poLineNumber = /Response/PoLineNumber

    # 4. Retrieve The Composite Order And Verify BillTo Is Populated With The Tenant Address ID
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0] + '*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].billTo == addressId
    * def orderId = response.purchaseOrders[0].id

    # 5. Delete Custom Mapping
    Given path '/gobi/orders/custom-mappings/UnlistedPrintMonograph'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    When method DELETE
    Then status 200

    # 6. Cleanup Order Data
    * def v = call cleanupOrderData { orderId: "#(orderId)" }

    # 7. Delete The Tenant Address
    Given path '/tenant-addresses', addressId
    And headers headersAdmin
    When method DELETE
    Then status 204
