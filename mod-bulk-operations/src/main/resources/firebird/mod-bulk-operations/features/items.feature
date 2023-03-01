Feature: mod bulk operations items features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-items.feature')
    * callonce login testUser
    * callonce variables
    * def itemBarcode = '7010'

  Scenario: In-App approach bulk edit of item
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'ITEM'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/items/items-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * pause(8000)

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

    * pause(8000)

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'MATCHED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200
    And match response.rows[0].row[9] == itemBarcode

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

    * pause(8000)

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

    * pause(8000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    Then status 200
    And match response.rows[0].row[33] contains 'Unknown'
    And match response.rows[0].row[36] == ''
    And match response.rows[0].row[37] == 'Selected'
    And match response.rows[0].row[39] == 'Annex'
    And match response.rows[0].row[40] == ''

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

    * pause(8000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[33] contains 'Unknown'
    And match response.rows[0].row[36] == ''
    And match response.rows[0].row[37] == 'Selected'
    And match response.rows[0].row[39] == 'Annex'
    And match response.rows[0].row[40] == ''

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

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
