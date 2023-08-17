Feature: mod bulk operations user positive scenarios

  Background:
    * url baseUrl
    * callonce login testUser
    * callonce variables
    * def query = 'barcode==' + userBarcode

  Scenario: In-App approach bulk edit of user
    * print 'In-App approach bulk edit of user'
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'USER'
    And param identifierType = 'BARCODE'
    And multipart file file = { read: 'classpath:samples/users/users-barcodes.csv', contentType: 'text/csv' }
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

    Given path 'users'
    And param query = query
    When method GET
    Then status 200
    And match response.users[0].personal.email == 'test@email.org'
    And match response.users[0].expirationDate == expirationDate
    And match response.users[0].patronGroup == '9ad391f4-da1c-4760-a9ef-5943dedf13b8'

  Scenario: Csv approach bulk edit of user
    * print 'Csv approach bulk edit of user'
    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/upload'
    And param entityType = 'USER'
    And param identifierType = 'BARCODE'
    And param manual = 'false'
    And multipart file file = { read: 'classpath:samples/users/users-barcodes.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * def operationId = $.id
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

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

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'UPLOAD'
    When method GET
    Then status 200

    * configure headers = { 'Content-Type': 'multipart/form-data', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

    Given path 'bulk-operations/upload'
    And param entityType = 'USER'
    And param identifierType = 'BARCODE'
    And param manual = 'true'
    And param operationId = operationId
    And multipart file file = { read: 'classpath:samples/users/user.csv', contentType: 'text/csv' }
    When method POST
    Then status 200

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * pause(5000)

    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
        "step":"EDIT",
        "approach":"MANUAL"
    }
    """
    When method POST
    Then status 200

    * pause(5000)

    Given path 'bulk-operations', operationId, 'start'
    And request
    """
    {
        "step":"COMMIT",
        "approach":"MANUAL"
    }
    """
    When method POST
    Then status 200

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'COMMIT'
    When method GET
    And match response.rows[0].row[6] == 'Original'
    And match response.rows[0].row[13] == 'test@email.com'
    And match response.rows[0].row[20] == '2200-01-11 00:00:00.000Z'

    Given path 'bulk-operations', operationId, 'errors'
    And param limit = '10'
    When method GET
    Then status 200
    And match response.total_records == 0

    Given path 'bulk-operations', operationId, 'download'
    And param fileContentType = 'COMMITTED_RECORDS_FILE'
    When method GET
    Then status 200

    Given path 'users'
    And param query = query
    When method GET
    Then status 200
    And match response.users[0].personal.email == 'test@email.com'
    And match response.users[0].expirationDate == '2200-01-11T00:00:00.000+00:00'
    And match response.users[0].patronGroup == '03f7690c-09e8-419f-97ec-2e753d0fa672'

  Scenario: Verify list-users endpoint
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'bulk-operations/list-users'
    And param query = '(entityType==\"USER\")'
    And param limit = 100
    And param offset = 0
    When method GET
    Then status 200
    And match response.total_records == 1