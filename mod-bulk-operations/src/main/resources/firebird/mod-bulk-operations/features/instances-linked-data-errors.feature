Feature: Verify instances with LINKED_DATA source are displayed in Errors & warnings accordion

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-instances.feature')
    * call login testUser
    * call variables

  Scenario: Verify LINKED_DATA instances show error when uploading by UUID
    # This scenario verifies that when uploading a CSV file with instance UUIDs that have
    # LINKED_DATA source, they are properly displayed in the "Errors & warnings" accordion
    # and cannot be processed in bulk operations.

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/linked-data-instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
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

    * pause(30000)

    # Verify that the preview does not contain information about the LINKED_DATA instance
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows == []

    # Verify that the errors preview contains the required error about the LINKED_DATA instance
    # This confirms the instance appears in the "Errors & warnings" accordion
    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.errors[0].message == 'Bulk edit of instances with source set to LINKED_DATA is not supported.'
    And match response.errors[0].type == 'ERROR'

    # Verify the bulk operation status reflects the error condition
    # Download and validate the CSV error file content
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'RECORD_MATCHING_ERROR_FILE'
    When method GET
    Then status 200
    * def cd = responseHeaders['Content-Disposition'][0]
    * def filename = cd.replaceAll('.*filename="([^"]+)".*', '$1')
    * def csvContent = response
    * def csvString = new java.lang.String(csvContent, 'UTF-8')
    * def csvLines = csvString.split('\n')
    * print 'Extracted filename:', filename
    And match csvLines[0] contains 'ERROR,in00000000237,Bulk edit of instances with source set to LINKED_DATA is not supported.'
    And match filename contains 'Matching-Records-Errors-linked-data-instance-hrids'
