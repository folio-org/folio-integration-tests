Feature: Generate default order template

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json, text/plain", "x-okapi-tenant": "#(testTenant)" }

    * configure headers = headersAdmin
    * callonce variables

  @Positive
  Scenario: Generate default order template
    # 1.1 Fetch the templates and verify that the default template is not present.
    Given path "/orders/order-templates"
    And param query = "templateName==Mosaic eBooks Default"
    And param limit = 1000
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 2.2 Fetch the default organization and verify that it is not present.
    Given path "/organizations/organizations"
    And param query = "name==Mosaic"
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 2. Call the endpoint to generate the default template.
    Given path "/mosaic/template"
    When method POST
    Then status 201

    # 3.1 Fetch the templates again and verify that the default template is now present.
    Given path "/orders/order-templates"
    And param query = "templateName==Mosaic eBooks Default"
    And param limit = 1000
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.orderTemplates[0].templateName == "Mosaic eBooks Default"

    # 3.2 Fetch the default organization and verify that it is created with the default template.
    Given path "/organizations/organizations"
    And param query = "name==Mosaic"
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.organizations[0].name == "Mosaic"
    And match response.organizations[0].code == "MOSAIC"
    And match response.organizations[0].status == "Active"

    # 4. Call the endpoint to generate the default template again.
    Given path "/mosaic/template"
    When method POST
    Then status 201

    # 5. Fetch the templates again and verify that there are no duplicate templates and the default template is still present.
    Given path "/orders/order-templates"
    And param query = "templateName==Mosaic eBooks Default"
    And param limit = 1000
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.orderTemplates[0].templateName == "Mosaic eBooks Default"
