@parallel=false
# for https://issues.folio.org/browse/MODORDERS-647
Feature: find-holdings-by-location-and-instance

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def locationId = 'fcd64ce1-6995-48f0-840e-89ffa2288371'

  Scenario: Create first order
    * def sample_po_1 = read('classpath:samples/mod-gobi/po-physical-annex-holding-1.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    And request sample_po_1
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

#   checked first order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0]+'*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true

  Scenario: Create second order
    * def sample_po_2 = read('classpath:samples/mod-gobi/po-physical-annex-holding-2.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

#   checked second order approved
    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0]+'*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true

#   matched order lines requested and stored information
    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].details.productIds[0].productId == '9780547572482'
    * def poLine = $.poLines[0]

#   for current instanceId and permanentLocationId have to be just one holding
    Given path '/holdings-storage/holdings'
    And param query = 'instanceId==' + poLine.instanceId + ' and permanentLocationId==' + locationId
    And headers headers
    When method GET
    Then status 200
    And match $.totalRecords == 1