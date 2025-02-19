Feature: mod bulk operations instances features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-instances.feature')
    * callonce login testUser
    * callonce variables
    * configure retry = { count: 5, interval: 10000 }


  Scenario: Prevent bulk edit of instances with LINKED_DATA source

    # This scenario verifies the error generation when attempting a bulk operation for
    # an instance with the source LINKED_DATA. To achieve this, an attempt is made to initiate
    # the bulk operation process for a pre-created instance with the source LINKED_DATA.

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/linked-data-instance-hrids.csv', contentType: 'text/csv' }
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

    # Verify that the preview does not contain information about an instance with the source LINKED_DATA.
    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows == []

    # Verify that the errors preview contains the required error about an instance with the source LINKED_DATA.
    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.errors[0].message == 'Bulk operation is not allowed for instances with source LINKED_DATA'
    And match response.errors[0].parameters[0].type == 'ERROR'

  Scenario: Edit staff suppress for instances
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[2] == 'false'
    And match response.rows[0].row[4] == instanceHRID

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
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[1] == 'false'
    And match response.rows[0].row[4] == instanceHRID

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
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
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
    And match response.rows[0].row[4] == instanceHRID

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
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'ID'
    And multipart file file = { read: 'classpath:samples/instances/marc-instances.csv', contentType: 'text/csv' }
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

    Given path 'bulk-operations', operationId
    And retry until response.status == 'REVIEW_CHANGES'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    And match response.rows[0].row[45] == 'new500'

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
    And retry until response.status == 'COMPLETED_WITH_ERRORS'
    When method GET
    Then status 200
    And match response.committedNumOfErrors == 2
    And match response.matchedNumOfRecords == 1
    And match response.processedNumOfRecords == 1
    And match response.totalNumOfRecords == 1
    And match response.committedNumOfRecords == 0
    And match response.linkToCommittedRecordsMarcFile == '#notpresent'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    And param offset = '0'
    And param errorType = ''
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.errors[0].parameters[0].key == 'IDENTIFIER'
    And match response.errors[1].parameters[0].key == 'IDENTIFIER'
    # Uncomment after https://folio-org.atlassian.net/browse/MODBULKOPS-413
#    And match response.errors[0].parameters[0].value == marcInstanceID
#    And match response.errors[1].parameters[0].value == marcInstanceID

  Scenario: Add statistical codes
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'INSTANCE'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/instances/instance-hrids.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[4] == instanceHRID
    And match response.rows[0].row[9] == '#null'

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
    And match response.rows[0].row[9] == 'RECM (Record mngmnt): compfiles1 - Computer files, CDs, etc (compfiles)1'

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
    And match response.rows[0].row[9] == 'RECM (Record mngmnt): compfiles1 - Computer files, CDs, etc (compfiles)1'

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

