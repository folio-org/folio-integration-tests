Feature: mod bulk operations items features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-items.feature')
    * callonce login testUser
    * callonce variables
    * def itemBarcode = '7010'

  Scenario: In-App approach bulk edit of item
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

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
                            "updated": "53cf956f-c1df-410b-8bea-27f712cca7c0"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "STATUS",
                    "actions": [{
                            "type": "REPLACE_WITH",
                            "initial": null,
                            "updated": "Unknown"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "TEMPORARY_LOAN_TYPE",
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
                    "option": "PERMANENT_LOAN_TYPE",
                    "actions": [{
                            "type": "REPLACE_WITH",
                            "initial": null,
                            "updated": "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845"
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
    Then status 200
    And match response.header[31].value == 'Action note'
    And match response.header[37].value == 'Reproduction note'
    And match response.rows[0].row[38] == 'Selected'
    And match response.rows[0].row[39] == '#null'
    And match response.rows[0].row[40] contains 'Unknown'
    And match response.rows[0].row[43] == 'Annex'
    And match response.rows[0].row[44] == '#null'

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
    And match response.header[31].value == 'Action note'
    And match response.header[37].value == 'Reproduction note'
    And match response.rows[0].row[38] == 'Selected'
    And match response.rows[0].row[39] == '#null'
    And match response.rows[0].row[40] contains 'Unknown'
    And match response.rows[0].row[43] == 'Annex'
    And match response.rows[0].row[44] == '#null'


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

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].status.name contains 'Unknown'
    And match response.items[0].temporaryLoanType.name == '#notpresent'
    And match response.items[0].permanentLoanType.name == 'Selected'
    And match response.items[0].permanentLocation.name == 'Annex'
    And match response.items[0].temporaryLocation.name == '#notpresent'

  Scenario: In-App approach add notes to item
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

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
                            "updated": "note"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "circ note"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "item note",
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "87c450be-2033-41fb-80ba-dd2409883681"}]
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "ADD_TO_EXISTING",
                            "initial": null,
                            "updated": "provenance note",
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "c3a539b9-9576-4e3a-b6de-d910200b2919"},
                                {
                                key: "STAFF_ONLY",
                                value: true}]
                        }
                    ]
                }
            }
        ],
        "totalRecords": 4
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
    And match response.header[32].value == 'Binding note'
    And match response.rows[0].row[32] == 'item note'

    * pause(15000)

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

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].administrativeNotes[0] == 'note'
    And match response.items[0].circulationNotes[0].note == 'circ note'
    And match response.items[0].circulationNotes[0].noteType == 'Check in'
    And match response.items[0].circulationNotes[0].staffOnly == false
    And match response.items[0].notes[0].note == 'item note'
    And match response.items[0].notes[0].itemNoteTypeId == '87c450be-2033-41fb-80ba-dd2409883681'
    And match response.items[0].notes[1].note == 'provenance note'
    And match response.items[0].notes[1].itemNoteTypeId == 'c3a539b9-9576-4e3a-b6de-d910200b2919'
    And match response.items[0].notes[1].staffOnly == true


  Scenario: In-App approach mark notes as staff only
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "87c450be-2033-41fb-80ba-dd2409883681"}]
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].circulationNotes[0].noteType == 'Check in'
    And match response.items[0].circulationNotes[0].staffOnly == true
    And match response.items[0].notes[0].itemNoteTypeId == '87c450be-2033-41fb-80ba-dd2409883681'
    And match response.items[0].notes[0].staffOnly == true


  Scenario: In-App approach remove mark as staff only for notes
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "REMOVE_MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "REMOVE_MARK_AS_STAFF_ONLY",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "87c450be-2033-41fb-80ba-dd2409883681"}]
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].circulationNotes[0].noteType == 'Check in'
    And match response.items[0].circulationNotes[0].staffOnly == false
    And match response.items[0].notes[0].itemNoteTypeId == '87c450be-2033-41fb-80ba-dd2409883681'
    And match response.items[0].notes[0].staffOnly == false

  Scenario: In-App approach find and replace for notes
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [ {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ADMINISTRATIVE_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REPLACE",
                            "initial": "note",
                            "updated": "updated note"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REPLACE",
                            "initial": "item note",
                            "updated": "updated item note",
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "87c450be-2033-41fb-80ba-dd2409883681"}]
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REPLACE",
                            "initial": "circ note",
                            "updated": "updated circ note"
                           }
                    ]
                }
            }
        ],
        "totalRecords": 3
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

    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].administrativeNotes[0] == 'updated note'
    And match response.items[0].circulationNotes[0].note == 'updated circ note'
    And match response.items[0].circulationNotes[0].noteType == 'Check in'
    And match response.items[0].notes[0].note == 'updated item note'
    And match response.items[0].notes[0].itemNoteTypeId == '87c450be-2033-41fb-80ba-dd2409883681'

  Scenario: In-App approach change type of notes
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

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
                            "updated": "acb3a58f-1d72-461d-97c3-0e7119e8d544"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "CHANGE_TYPE",
                            "initial": null,
                            "updated": "ADMINISTRATIVE_NOTE",
                             "parameters":[{
                                 key: "ITEM_NOTE_TYPE_ID_KEY",
                                 value: "87c450be-2033-41fb-80ba-dd2409883681"}]
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "CHANGE_TYPE",
                            "initial": null,
                            "updated": "CHECK_OUT_NOTE"
                           }
                    ]
                }
            }
        ],
        "totalRecords": 3
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].administrativeNotes[0] == 'updated item note'
    And match response.items[0].circulationNotes[0].note == 'updated circ note'
    And match response.items[0].circulationNotes[0].noteType == 'Check out'
    And match response.items[0].notes[1].note == 'updated note'
    And match response.items[0].notes[1].itemNoteTypeId == 'acb3a58f-1d72-461d-97c3-0e7119e8d544'

  Scenario: In-App approach duplicate for circ notes
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_OUT_NOTE",
                    "actions": [{
                            "type": "DUPLICATE",
                            "initial": null,
                            "updated": "CHECK_IN_NOTE"
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].circulationNotes[0].note == 'updated circ note'
    And match response.items[0].circulationNotes[0].noteType == 'Check out'

  Scenario: In-App approach find and remove for notes
    * call login testUser
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

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
                            "initial": "updated item note",
                            "updated": null
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "updated note",
                            "updated": null,
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "acb3a58f-1d72-461d-97c3-0e7119e8d544"}]
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "updated circ note",
                            "updated": null
                           }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_OUT_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "updated circ note",
                            "updated": null
                           }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "FIND_AND_REMOVE_THESE",
                            "initial": "provenance note",
                            "updated": null,
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "c3a539b9-9576-4e3a-b6de-d910200b2919"}]
                           }
                    ]
                }
            }
        ],
        "totalRecords": 5
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].administrativeNotes[0] == ''
    And match response.items[0].circulationNotes[0].note == ''
    And match response.items[0].notes[0].note == ''

  Scenario: In-App approach remove notes
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200

    * def item = response.items[0]
    * def itemId = item.id
    * item.administrativeNotes = ['administrative note']
    * item.circulationNotes = [{'noteType': 'Check in', 'note': 'circ note'}, {'noteType': 'Check out', 'note': 'circ note'}]
    * item.notes = [{'itemNoteTypeId': 'acb3a58f-1d72-461d-97c3-0e7119e8d544', 'note': 'item note'}]

    Given path 'inventory', 'items', itemId
    And request item
    When method PUT

    * call login testUser
    * def itemBarcode = '7010'
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(15000)

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
    And match response.rows[0].row[7] == itemBarcode

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
                    "option": "ITEM_NOTE",
                    "actions": [{
                            "type": "REMOVE_ALL",
                            "initial": null,
                            "updated": null,
                            "parameters":[{
                                key: "ITEM_NOTE_TYPE_ID_KEY",
                                value: "acb3a58f-1d72-461d-97c3-0e7119e8d544"}]
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "CHECK_IN_NOTE",
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
                    "option": "CHECK_OUT_NOTE",
                    "actions": [{
                            "type": "REMOVE_ALL",
                            "initial": null,
                            "updated": null
                           }
                    ]
                }
            }
        ],
        "totalRecords": 4
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
    And match response.totalRecords == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode==' + itemBarcode
    Given path 'inventory', 'items'
    And param query = query
    When method GET
    Then status 200
    And match response.items[0].administrativeNotes[0] == '#notpresent'
    And match response.items[0].circulationNotes[0] == '#notpresent'
    And match response.items[0].notes[0] == '#notpresent'
