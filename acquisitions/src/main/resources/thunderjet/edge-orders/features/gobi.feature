@parallel=false
Feature: Edge Orders GOBI

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login  testUser
    * def folioHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def edgeHeaders = { 'Content-Type': 'application/xml', 'Accept': 'application/xml' }

    * def apiKey = 'eyJzIjoiYmRnZ2dvM0lwbHdvIiwidCI6InRlc3RlZGdlb3JkZXJzIiwidSI6InRlc3QtdXNlciJ9'
    * configure lowerCaseResponseHeaders = true

  Scenario: Create GOBI organization
    Given path 'organizations/organizations', 'c6dace5d-4574-411e-8ba1-036102fcdc93'
    And headers folioHeaders
    When method DELETE
    Then status 204

    * def gobi_org = read('classpath:samples/edge-orders/gobi/gobi-organization.json')
    Given path 'organizations/organizations'
    And headers folioHeaders
    And request gobi_org
    When method POST
    Then status 201

  Scenario: Validate apiKey using XML
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers { 'Accept': 'application/xml' }
    When method GET
    Then status 200
    And match responseHeaders['content-type'][0] == 'application/xml'
    And match /test == 'GET - OK'

  Scenario: Validate apiKey using JSON
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers { 'Accept': 'application/json' }
    When method GET
    Then status 400
    And match responseHeaders['content-type'][0] == 'application/json'
    And match $.Error.Code == "BAD_REQUEST"

  Scenario: Validate Create Order
    * def sample_po_1 = read('classpath:samples/edge-orders/gobi/po-listed-electronic-serial.xml')
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers edgeHeaders
    And request sample_po_1
    When method POST
    Then status 200
    And match responseHeaders['content-type'][0] == 'application/xml'
    And match /test == 'POST - OK'

  Scenario: Create and Check Order
    * def sample_po_2 = read('classpath:samples/edge-orders/gobi/po-listed-print-monograph.xml')
    Given url edgeUrl
    And path 'orders'
    And param type = 'GOBI'
    And param apiKey = apiKey
    And headers edgeHeaders
    And request sample_po_2
    When method POST
    Then status 201
    And match responseHeaders['content-type'][0] == 'application/xml'
    * def poLineNumber = /Response/PoLineNumber

    Given url baseUrl
    Given path 'orders/order-lines'
    And param query = 'poLineNumber==' + poLineNumber
    And headers folioHeaders
    When method GET
    Then status 200
    And match $.poLines == '#[1]'
    And match $.poLines[0].titleOrPackage == 'MAN IN THE HIGH CASTLE.'
