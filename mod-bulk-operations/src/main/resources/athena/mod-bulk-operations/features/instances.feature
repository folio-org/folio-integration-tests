Feature: mod bulk operations instances features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-instances.feature')
    * callonce login testUser
    * callonce variables
    * configure retry = { count: 5, interval: 10000 }

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

  Scenario: Edit staff suppress for instances
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[2] == 'false'
    And match response.rows[0].row[5] == instanceHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "STAFF_SUPPRESS",
                    "actions": [{
                            "type": "SET_TO_TRUE",
                            "initial": null,
                            "updated": ""
                        }
                    ]
                }
            }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[2] == 'true'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].hrid == instanceHRID
    And match response.instances[0].staffSuppress == true

  Scenario: Edit suppress from discovery including holdings
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[1] == 'false'
    And match response.rows[0].row[5] == instanceHRID

    * def query = 'hrid==' + instanceFeatureHoldingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].hrid == instanceFeatureHoldingHRID
    And match response.holdingsRecords[0].discoverySuppress == '#notpresent'
    * def holdingsId = response.holdingsRecords[0].id

    * def query = 'holdingsRecordId==' + holdingsId
    Given path 'inventory/items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].discoverySuppress == '#null'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "SUPPRESS_FROM_DISCOVERY",
                    "actions": [{
                            "type": "SET_TO_TRUE",
                            "initial": null,
                            "updated": "",
                            "parameters": [
                            {
                                "key": "APPLY_TO_HOLDINGS",
                                "value": "true"
                            },
                            {
                                "key": "APPLY_TO_ITEMS",
                                "value": "false"
                            }
                        ]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[1] == 'true'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[1] == 'true'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].hrid == instanceHRID
    And match response.instances[0].discoverySuppress == true

    * def query = 'hrid==' + instanceFeatureHoldingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].hrid == instanceFeatureHoldingHRID
    And match response.holdingsRecords[0].discoverySuppress == true
    * def holdingsId = response.holdingsRecords[0].id

    * def query = 'holdingsRecordId==' + holdingsId
    Given path 'inventory/items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].discoverySuppress == '#null'

  Scenario: Edit suppress from discovery including items
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def operationId = $.id

    * def holding = read('classpath:samples/instances/holdings.json')
    * set holding._version = 2
    Given path 'holdings-storage/holdings', holding.id
    And request holding
    When method PUT
    Then status 204

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
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[5] == instanceHRID

    * def query = 'hrid==' + instanceFeatureHoldingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].hrid == instanceFeatureHoldingHRID
    And match response.holdingsRecords[0].discoverySuppress == '#notpresent'
    * def holdingsId = response.holdingsRecords[0].id

    * def query = 'holdingsRecordId==' + holdingsId
    Given path 'inventory/items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].discoverySuppress == '#null'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "SUPPRESS_FROM_DISCOVERY",
                    "actions": [{
                            "type": "SET_TO_TRUE",
                            "initial": null,
                            "updated": "",
                            "parameters": [
                            {
                                "key": "APPLY_TO_HOLDINGS",
                                "value": "false"
                            },
                            {
                                "key": "APPLY_TO_ITEMS",
                                "value": "true"
                            }
                        ]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[2] == 'true'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.errors[0].message == 'No change in value for instance required, unsuppressed associated records have been updated.'
    And match response.errors[0].parameters[0].value == instanceHRID

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].hrid == instanceHRID
    And match response.instances[0].discoverySuppress == true

    * def query = 'hrid==' + instanceFeatureHoldingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].hrid == instanceFeatureHoldingHRID
    And match response.holdingsRecords[0].discoverySuppress == '#notpresent'
    * def holdingsId = response.holdingsRecords[0].id

    * def query = 'holdingsRecordId==' + holdingsId
    Given path 'inventory/items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].discoverySuppress == true

  Scenario: Edit marc instances with duplicate SRS
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'ID'
    And multipart file file = { read: 'classpath:samples/instances/marc-instances.csv', contentType: 'text/csv' }
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
    # Duplicate instance with id=f4529ca9-3720-4967-ac5f-9ed2d37ade9c will be skipped and sent to errors.
    And match karate.sizeOf(response.rows) == 1
    And match response.rows[0].row[0] == '55529ca9-3720-4967-ac5f-9ed2d37ade9c'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.errors[0].message == 'Multiple SRS records are associated with the instance. The following SRS have been identified: 2b2719bb-e9d3-4958-bd4f-55d80e433ea4, 55f49e25-de64-40ef-9963-7484b0b37e7d.'

    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
    """
      {
        "bulkOperationMarcRules": [
          {
            "bulkOperationId": "#(operationId)",
            "id": "1",
            "tag": "500",
            "ind1": "\\",
            "ind2": "\\",
            "subfield": "a",
            "actions": [
                {
                    "name": "ADD_TO_EXISTING",
                    "data": [
                        {
                            "key": "VALUE",
                            "value": "new500"
                        }
                    ]
                },
                {
                    "name": "",
                    "data": []
                }
            ],
            "parameters": [],
            "subfields": []
          }
        ],
        "totalRecords": 1
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

    * pause(30000)
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations', operationId
    And retry until response.status == 'REVIEW_CHANGES'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    And match response.rows[0].row[47] == 'new500'

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

    * pause(30000)

    Given path 'bulk-operations', operationId
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.committedNumOfRecords == 1
    And match response.processedNumOfRecords == 1
    And match response.committedNumOfErrors == 0
    And match response.matchedNumOfRecords == 1
    And match response.totalNumOfRecords == 1
    And match response.matchedNumOfErrors == 1
    And match response.matchedNumOfWarnings == 0
    And match response.committedNumOfWarnings == 0
    And match response.linkToCommittedRecordsMarcFile == '#present'

  Scenario: Add statistical codes
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[5] == instanceHRID
    And match response.rows[0].row[10] == '#null'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "STATISTICAL_CODE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "7776b1c1-c9df-445c-8deb-68bb3580edc2"
                        }
                    ]
                }
            }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[10] == 'RECM (Record mngmnt): compfiles1 - Computer files, CDs, etc (compfiles)1'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[10] == 'RECM (Record mngmnt): compfiles1 - Computer files, CDs, etc (compfiles)1'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].hrid == instanceHRID
    And match response.instances[0].statisticalCodeIds == ['7776b1c1-c9df-445c-8deb-68bb3580edc2']

  Scenario: Skip SRS update if inventory instance update fails
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'ID'
    And multipart file file = { read: 'classpath:samples/instances/marc-instance-uuid.csv', contentType: 'text/csv' }
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
    * def instanceId = response.rows[0].row[0]

    Given path 'bulk-operations', operationId, 'content-update'
    And request
      """
      {
        "bulkOperationRules": [
          {
            "bulkOperationId": "#(operationId)",
            "rule_details": {
              "option": "ADMINISTRATIVE_NOTE",
              "tenants": [],
              "actions": [
                {
                  "type": "ADD_TO_EXISTING",
                  "updated": "new note",
                  "parameters": [],
                  "tenants": [],
                  "updated_tenants": []
                }
              ]
            }
          }
        ],
        "totalRecords": 1
      }
      """
    When method POST
    Then status 200

    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
      """
      {
        "bulkOperationMarcRules": [
          {
            "tag": "500",
            "ind1": "\\",
            "ind2": "\\",
            "subfield": "a",
            "actions": [
              {
                "name": "ADD_TO_EXISTING",
                "data": [
                  {
                    "key": "VALUE",
                    "value": "new general note"
                  }
                ]
              }
            ],
            "parameters": [],
            "subfields": [],
            "bulkOperationId": "#(operationId)"
          }
        ],
        "totalRecords": 1
      }
      """
    When method POST
    Then status 200

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

    Given path 'bulk-operations', operationId
    And retry until response.status == 'REVIEW_CHANGES'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    And match response.rows[0].row[11] == 'new note'
    And match response.rows[0].row[47] == 'new general note | new500'

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'PROPOSED_CHANGES_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'PROPOSED_CHANGES_MARC_FILE'
    When method GET
    Then status 200

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    * def instanceJson = response
    * instanceJson.administrativeNotes = ['note']

    Given path 'inventory/instances', instanceId
    And request instanceJson
    When method PUT
    Then status 204

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows.length == '#notpresent'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 1

    Given path 'bulk-operations', operationId
    When method GET
    Then status 200
    And match response.linkToCommittedRecordsCsvFile == '#notpresent'
    And match response.linkToCommittedRecordsMarcFile == '#notpresent'

  Scenario: Set FOLIO instance for deletion, staff and discovery suppress must be true
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def folioInstanceId = '04eaba65-4846-4e03-abf6-00d3ab47cb2d'
    Given path 'inventory/instances', folioInstanceId
    When method GET
    Then status 200
    * def instanceJson = response
    * instanceJson.deleted = false
    * instanceJson.staffSuppress = false
    * instanceJson.discoverySuppress = false

    Given path 'inventory/instances', folioInstanceId
    And request instanceJson
    When method PUT
    Then status 204

    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[4] == 'false'
    # Make sure staff and discovery suppress are false
    And match response.rows[0].row[1] == 'false'
    And match response.rows[0].row[2] == 'false'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
      """
      {
        "bulkOperationRules": [
          {
            "bulkOperationId": "#(operationId)",
            "rule_details": {
              "option": "SET_RECORDS_FOR_DELETE",
              "tenants": [],
              "actions": [
                {
                  "type": "SET_TO_TRUE",
                  "parameters": [],
                  "tenants": [],
                  "updated_tenants": []
                }
              ]
            }
          }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[4] == 'true'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[4] == 'true'
    # Staff suppress and discovery suppress must be 'true' as well
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].deleted == true
    And match response.instances[0].discoverySuppress == true
    And match response.instances[0].staffSuppress == true

  Scenario: Unset FOLIO instance for deletion, staff and discovery suppress should remain true
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[4] == 'true'
    # Make sure staff and discovery suppress are false
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
      """
      {
        "bulkOperationRules": [
          {
            "bulkOperationId": "#(operationId)",
            "rule_details": {
              "option": "SET_RECORDS_FOR_DELETE",
              "tenants": [],
              "actions": [
                {
                  "type": "SET_TO_FALSE",
                  "parameters": [],
                  "tenants": [],
                  "updated_tenants": []
                }
              ]
            }
          }
        ],
        "totalRecords": 1
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
    And match response.rows[0].row[4] == 'false'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[4] == 'false'
    # Staff suppress and discovery suppress should be unchanged
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + instanceHRID
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    And match response.instances[0].deleted == false
    And match response.instances[0].discoverySuppress == true
    And match response.instances[0].staffSuppress == true

  Scenario: Set MARC instance for deletion, LDR should be set to 'd', discoverySuppress to 'true', deleted to 'true'
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def marcInstanceId = '55529ca9-3720-4967-ac5f-9ed2d37ade9c'
    Given path 'inventory/instances', marcInstanceId
    When method GET
    Then status 200
    * def instanceJson = response
    * instanceJson.deleted = false
    * instanceJson.staffSuppress = false
    * instanceJson.discoverySuppress = false

    Given path 'inventory/instances', marcInstanceId
    And request instanceJson
    When method PUT
    Then status 204

    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'ID'
    And multipart file file = { read: 'classpath:samples/instances/marc-instance.csv', contentType: 'text/csv' }
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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    # Make sure 'deleted' is false
    And match response.rows[0].row[4] == 'false'
    # Make sure staff and discovery suppress are false
    And match response.rows[0].row[1] == 'false'
    And match response.rows[0].row[2] == 'false'

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'content-update'
    And request
      """
      {
        "bulkOperationRules": [
          {
            "bulkOperationId": "#(operationId)",
            "rule_details": {
              "option": "SET_RECORDS_FOR_DELETE",
              "tenants": [],
              "actions": [
                {
                  "type": "SET_TO_TRUE",
                  "parameters": [],
                  "tenants": [],
                  "updated_tenants": []
                }
              ]
            }
          }
        ],
        "totalRecords": 1
      }
      """
    When method POST
    Then status 200

    Given path 'bulk-operations', operationId, 'marc-content-update'
    And request
      """
      {
        "bulkOperationMarcRules": [
        ],
        "totalRecords": 0
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
    And match response.rows[0].row[4] == 'true'
    # Make sure staff and discovery suppress are true as well
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'PROPOSED_CHANGES_FILE'
    When method GET
    Then status 200

    # Check .mrc file on Are u sure? form
    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'PROPOSED_CHANGES_MARC_FILE'
    When method GET
    Then status 200
    * def marcLine = new java.lang.String(response, 'utf-8')
    * print 'MARC line: ', marcLine
    * def leaderStatus = marcLine.substring(5, 6)
    And match leaderStatus == 'd'

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

    * pause(15000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[4] == 'true'
    # Staff suppress and discovery suppress should be true as well
    And match response.rows[0].row[1] == 'true'
    And match response.rows[0].row[2] == 'true'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_MARC_FILE'
    When method GET
    Then status 200
    * def marcLine = new java.lang.String(response, 'utf-8')
    * print 'MARC line: ', marcLine
    * def leaderStatus = marcLine.substring(5, 6)
    And match leaderStatus == 'd'

    * def query = 'id==' + marcInstanceId
    Given path 'inventory/instances'
    And param query = query
    When method GET
    Then status 200
    # Also recheck an actual instance in inventory
    And match response.instances[0].deleted == true
    And match response.instances[0].discoverySuppress == true
    And match response.instances[0].staffSuppress == true

    # Also check updated SRS record
    Given path '/source-storage/stream/source-records'
    And param externalId = marcInstanceId
    And param deleted = true
    When method GET
    Then status 200
    And match response.deleted == true
    And match response.additionalInfo.suppressDiscovery == true
    * def leaderLine = response.parsedRecord.content.leader
    * def leaderStatus = leaderLine.substring(5, 6)
    And match leaderStatus == 'd'