Feature: mod bulk operations holdings features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-holdings.feature')
    * callonce login testUser
    * callonce variables

  Scenario: In-App approach bulk edit of holdings
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "TEMPORARY_LOCATION",
                    "actions": [{
                            "type": "CLEAR_FIELD",
                            "initial": null,
                            "updated": ""
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "PERMANENT_LOCATION",
                    "actions": [{
                            "type": "REPLACE_WITH",
                            "initial": null,
                            "updated": "a551764c-1466-4e1d-a028-1a3684a5da99"
                        }
                    ]
                }
            }, {
               "bulkOperationId": "#(operationId)",
                "rule_details": {
                     "option": "SUPPRESS_FROM_DISCOVERY",
                     "actions": [{
                             "type": "SET_TO_TRUE",
                             "initial": null,
                             "updated": null
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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    And match response.rows[0].row[6] == 'Popular Reading Collection 139'
    And match response.rows[0].row[7] == '#null'

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[6] == 'Popular Reading Collection 139'
    And match response.rows[0].row[7] == '#null'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].permanentLocation.name == 'Popular Reading Collection 139'
    And match response.holdingsRecords[0].temporaryLocation.name == '#notpresent'
    And match response.holdingsRecords[0].hrid == holdingHRID
    And match response.holdingsRecords[0].discoverySuppress == true

  Scenario: In-App add notes for holdings
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ADMINISTRATIVE_NOTE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "note1"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "note2",
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "b160f13a-ddba-4053-b9c4-60ec5ea45d56"}]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(5000)

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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].administrativeNotes[0] == 'note1'
    And match response.holdingsRecords[0].notes[0].note == 'note2'

  Scenario: In-App approach mark notes as staff only
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "b160f13a-ddba-4053-b9c4-60ec5ea45d56"}]
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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].notes[0].note == 'note2'
    And match response.holdingsRecords[0].notes[0].staffOnly == true

  Scenario: In-App approach remove mark as staff only for notes
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "REMOVE_MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "b160f13a-ddba-4053-b9c4-60ec5ea45d56"}]
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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].notes[0].note == 'note2'
    And match response.holdingsRecords[0].notes[0].staffOnly == false

  Scenario: In-App approach find and replace for notes

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REPLACE",
                            "initial": "note2",
                            "updated": "updated note2",
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "b160f13a-ddba-4053-b9c4-60ec5ea45d56"}]
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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].notes[0].note == 'updated note2'

  Scenario: In-App approach change type of notes

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ADMINISTRATIVE_NOTE",
                    "actions": [{
                            "type": "CHANGE_TYPE",
                            "initial": null,
                            "updated": "db9b4787-95f0-4e78-becf-26748ce6bdeb"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "CHANGE_TYPE",
                            "initial": null,
                            "updated": "ADMINISTRATIVE_NOTE",
                             "parameters":[{
                                 key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                 value: "b160f13a-ddba-4053-b9c4-60ec5ea45d56"}]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].administrativeNotes[0] == 'updated note2'
    And match response.holdingsRecords[0].notes[0].note == 'note1'
    And match response.holdingsRecords[0].notes[0].holdingsNoteTypeId == 'db9b4787-95f0-4e78-becf-26748ce6bdeb'

  Scenario: In-App approach find and remove for notes

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ADMINISTRATIVE_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "updated note2",
                            "updated": null
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "note1",
                            "updated": null,
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "db9b4787-95f0-4e78-becf-26748ce6bdeb"}]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].administrativeNotes[0] == '#notpresent'
    And match response.holdingsRecords[0].notes[0].note == '#notpresent'
    And match response.holdingsRecords[0].notes[0].holdingsNoteTypeId == '#notpresent'

  Scenario: In-App approach remove notes
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200

    * def holding = response.holdingsRecords[0]
    * def holdingId = holding.id
    * holding.administrativeNotes = ['note1']
    * holding.notes = [{'holdingsNoteTypeId': 'db9b4787-95f0-4e78-becf-26748ce6bdeb', 'note': 'note2'}]

    Given path 'holdings-storage', 'holdings', holdingId
    And request holding
    When method PUT

    * callonce login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'HOLDINGS_RECORD'
    And param identifierType = 'HRID'
    And multipart file file = { read: 'classpath:samples/holdings/holdings-hrids.csv', contentType: 'text/csv' }
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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[2] == holdingHRID

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ADMINISTRATIVE_NOTE",
                    "actions": [{
                            "type": "REMOVE_ALL",
                            "initial": null,
                            "updated": null
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "HOLDINGS_NOTE",
                    "actions": [{
                            "type": "REMOVE_ALL",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "HOLDINGS_NOTE_TYPE_ID_KEY",
                                value: "db9b4787-95f0-4e78-becf-26748ce6bdeb"}]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 2
    }
    """
    When method POST
    Then status 200

    * pause(5000)

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

    * pause(5000)

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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'hrid==' + holdingHRID
    Given path 'holdings-storage/holdings'
    And param query = query
    When method GET
    Then status 200
    And match response.holdingsRecords[0].administrativeNotes[0] == '#notpresent'
    And match response.holdingsRecords[0].notes[0].note == '#notpresent'
    And match response.holdingsRecords[0].notes[0].holdingsNoteTypeId == '#notpresent'