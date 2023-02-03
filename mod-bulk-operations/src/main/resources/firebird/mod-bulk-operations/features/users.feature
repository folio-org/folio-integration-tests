Feature: mod bulk operations user features

  Background:
    * url baseUrl
    * callonce read('init-data/init-data-for-users.feature')
    * callonce login testUser
    * callonce variables

  Scenario: Inn-App approach bulk edit of user
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

    * def expirationDate = userExpirationDate()

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
            },
		    {
                "bulkOperationId": "#(operationId)",
                "rule_details": {
                    "option": "EXPIRATION_DATE",
                    "actions": [{
                            "type": "REPLACE_WITH",
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

    * pause(10000)

    Given path 'bulk-operations', operationId, 'preview'
    And param limit = '10'
    And param step = 'EDIT'
    When method GET