Feature: mod bulk operations holdings features in ecs

  Background:
    * url baseUrl
    * callonce read(login) consortiaAdmin
    * callonce variables

  Scenario: In-App approach bulk edit of holdings
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200
    * pause(6000)
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def operationId = $.id

    Given path 'bulk-operations', operationId, 'start'
    And request
    """
      {
       "step": "UPLOAD"
      }
    """
    When method POST
    Then status 200

    * pause(15000)

    Given path 'bulk-operations', operationId, 'download'
    And header x-okapi-tenant = centralTenant
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And header x-okapi-tenant = centralTenant
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[3] == holdingHRID