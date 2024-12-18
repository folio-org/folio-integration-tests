Feature: mod bulk operations MARC instances features

  Background:
    * url baseUrl
    * callonce read('init-data/import-marc-record.feature')
    * callonce login testUser

  Scenario: MARC instances - add new field
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { value: '#(instanceHrid)', contentType: 'text/csv', filename: 'instance-hrid.csv' }
    When method POST
    Then status 200

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
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
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
#    And match response.rows[0].row[2] == '#null'
#    And match response.rows[0].row[4] == instanceHRID

    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
    {
    "bulkOperationMarcRules": [
        {
          "bulkOperationId": "#(operationId)",
          "tag": "502",
          "ind1": "\\",
          "ind2": "\\",
          "subfield": "a",
          "actions": [
            {
              "name": "ADD_TO_EXISTING",
              "data": [
                {
                  "key": "VALUE",
                  "value": "New dissertation note"
                }
              ]
            }
        ],
        "parameters": null,
        "subfields": null
      }],
      "totalRecords" : 1
    }
    """
    When method POST
    Then status 200

    * pause(15000)

    Given path 'bulk-operations', operationId, 'start'
    And request
      """
      {
        "step":"EDIT",
        "approach":"IN_APP"
      }
      """
    When method POST
    Then status 200

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    Then status 200
#    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'PROPOSED_CHANGES_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
        "step":"COMMIT",
        "approach":"IN_APP"
    }
    """
    When method POST
    Then status 200

    * pause(60000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    Then status 200
#    And match response.rows[0].row[2] == 'true'

#    Given path 'bulk-operations', operationId, 'errors'
#    And param limit = '10'
#    When method GET
#    Then status 200
#    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHrid
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].hrid == instanceHrid
