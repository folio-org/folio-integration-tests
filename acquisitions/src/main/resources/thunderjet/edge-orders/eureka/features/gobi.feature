@parallel=false
Feature: Edge Orders GOBI

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin
    * def apiKey = 'eyJzIjoiYmRhd25vM0lwbHdvIiwidCI6ImRpa3UiLCJ1IjoiZGlrdV9hZG1pbiJ9Cg=='
    * configure lowerCaseResponseHeaders = true

  Scenario: Create GOBI organization
    * def gobi_org = read('classpath:samples/edge-orders/gobi/gobi-organization.json')
    Given path 'organizations-storage/organizations'
    And request gobi_org
    When method POST
    Then status 201

  Scenario: Validate apiKey using XML
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers { 'Accept': 'application/xml'  }
    When method GET
    Then status 200
    And match responseHeaders['content-type'][0] == 'application/xml'
    And match /test == 'GET - OK'

  Scenario: Validate apiKey using JSON
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers { 'Accept': 'application/json'  }
    When method GET
    Then status 400
    And match responseHeaders['content-type'][0] == 'application/json'
    And match $.Error.Code == "BAD_REQUEST"

  Scenario: Validate POST
    * def sample_po_1 = read('classpath:samples/edge-orders/gobi/po-listed-electronic-serial.xml')
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And request sample_po_1
    When method POST
    Then status 200
    And match responseHeaders['content-type'][0] == 'application/xml'
    And match /test == 'POST - OK'

  Scenario: POST
    * def sample_po_2 = read('classpath:samples/edge-orders/gobi/po-listed-print-monograph.xml')
    Given url edgeUrl
    And path 'orders'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['content-type'][0] == 'application/xml'
    And match /Response/PoLineNumber == '10000-1'

  Scenario: Check New Order Line
    * def poLineNumber = '10000-1'
    Given path 'orders/order-lines'
    And param query = 'poLineNumber==' + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == '#[1]'
    And match $.poLines[0].titleOrPackage == 'MAN IN THE HIGH CASTLE.'
