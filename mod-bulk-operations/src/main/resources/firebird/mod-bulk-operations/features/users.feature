Feature: mod bulk operations user features

  Background:
    * url baseUrl
    * karate.callSingle('init-data/init-data-for-users.feature');
    * callonce login testUser
    * callonce variables

  Scenario: In-App approach bulk edit of user
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'USER'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/users-barcodes.csv', contentType: 'text/csv' }
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
    And match response.rows[0].row[3] == userBarcode

    * def expirationDate = '2100-01-11T00:00:00.000+00:00'

    Given path 'bulk-operations', operationId, 'content-update'
    And request
    """
    {
        "bulkOperationRules": [{
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "EMAIL_ADDRESS",
                    "actions": [{
                            "type": "FIND_AND_REPLACE",
                            "initial": ".com",
                            "updated": ".org"
                        }
                    ]
                }
            }, {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "PATRON_GROUP",
                    "actions": [{
                            "type": "REPLACE_WITH",
                            "initial": "03f7690c-09e8-419f-97ec-2e753d0fa672",
                            "updated": "9ad391f4-da1c-4760-a9ef-5943dedf13b8"
                        }
                    ]
                }
            },  {
                 "bulkOperationId": "#(operationId)",
                 "rule_details": {
                    "option": "EXPIRATION_DATE",
                    "actions": [{
                            "type": "REPLACE_WITH",
                            "initial": "2020-01-11T00:00:00.000+00:00",
                            "updated": "#(expirationDate)"
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

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET
    And match response.rows[0].row[6] == 'Changed'
    And match response.rows[0].row[13] == 'test@email.org'
    And match response.rows[0].row[20] == '2100-01-11 00:00:00.000Z'

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

    * pause(5000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[6] == 'Changed'
    And match response.rows[0].row[13] == 'test@email.org'
    And match response.rows[0].row[20] == '2100-01-11 00:00:00.000Z'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    * def query = 'barcode=' + userBarcode

    Given path 'users'
    And param query = query
    When method GET
    Then status 200
    And match response.users[0].personal.email == 'test@email.org'
    And match response.users[0].expirationDate == expirationDate
    And match response.users[0].patronGroup == '9ad391f4-da1c-4760-a9ef-5943dedf13b8'