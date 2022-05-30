Feature: mod-gobi integration tests

  Background:
    * url baseUrl


 # Test tenant name creation:

    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  # Init global data

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

  Scenario: POST an order
    * def sample_po_2 = read('classpath:samples/mod-gobi/po-listed-electronic-monograph.xml')
    Given path '/gobi/orders'
    And headers { 'Content-Type': 'application/xml', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['Content-Type'][0] == 'application/xml'





