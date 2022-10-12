Feature: mod-gobi api tests

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Validate user
    Given path '/gobi/validate'
    And headers headers
    When method GET
    Then status 200
    And match /test == 'GET - OK'

  Scenario: Validate post user
    Given path '/gobi/validate'
    And headers headers
    When method POST
    Then status 200
    And match /test == 'POST - OK'

  Scenario: Creating an order and Checking fields of the order to match with requested data
    * def sample_po_2 = read('classpath:samples/mod-gobi/po-listed-electronic-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

    Given path '/orders/composite-orders'
    And headers headers
    And param query = 'poNumber==*' + poLineNumber.split('-')[0]+'*'
    When method GET
    Then status 200
    And match response.purchaseOrders[0].approved == true

    Given path '/orders/order-lines'
    And param query = 'poLineNumber=="*' + poLineNumber + '*"'
    And headers headers
    When method GET
    Then status 200
    And match $.poLines[0].checkinItems == false
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
    And match $.poLines[0].titleOrPackage == 'LIVING WITH THE UN[electronic resource] :AMERICAN RESPONSIBILITIES AND INTERNATIONAL ORDER.'
    And match $.poLines[0].vendorDetail.referenceNumbers[0].refNumber == '99952919209'
