Feature: File extensions

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': '*/*'  }
    * configure headers = headersUser

  Scenario: Get non-existent file extension

    * print 'Verify 404 response'

    Given path '/data-import/fileExtensions/dfgh'
    When method GET
    Then status 404

  Scenario Outline: Create file extension

    * print 'Create file extension'

    Given path '/data-import/fileExtensions'
    And request
    """
    {
      "importBlocked": false,
      "description": "",
      "dataTypes": [
        "<dataType>"
      ],
      "extension": "<extension>"
    }
    """
    When method POST
    Then status 201

    Examples:
      | dataType | extension |
      | EDIFACT  | .dfo      |
      | MARC     | .gje      |

  Scenario: Update existing file extension

    * print 'Create and then update a file extension'

    Given path '/data-import/fileExtensions'
    And request
    """
    {
      "importBlocked": false,
      "description": "",
      "dataTypes": [
        "MARC"
      ],
      "extension": ".dfa"
    }
    """
    When method POST
    Then status 201

    * def existingFileId = $.id

    Given path '/data-import/fileExtensions', existingFileId
    And request
    """
    {
      "id": "#(existingFileId)",
      "description": "FAT-139",
      "extension": ".dfa",
      "dataTypes": [
        "MARC"
      ],
      "importBlocked": false
    }
    """
    When method PUT
    Then status 200

    * print 'Delete file extension'

    Given path '/data-import/fileExtensions', existingFileId
    When method DELETE
    Then status 204

  Scenario: Fail to duplicate existing file extension

    * print 'Try to create file extension with the same name'

    Given path '/data-import/fileExtensions'
    And request
    """
    {
      "importBlocked": false,
      "description": "",
      "extension": ".edi",
      "dataTypes": [
        "EDIFACT"
      ]
    }
    """
    When method POST
    Then status 422

  Scenario: Fail to save invalid file extension

    * print 'Try to create file extension with empty body, incorrect name, and invalid field'

    Given path '/data-import/fileExtensions'
    And request
    """
    {
      "importBlocked": false,
      "description": "",
      "extension": "",
      "dataTypes": [
        "EDIFACT"
      ]
    }
    """
    When method POST
    Then status 422

  Scenario: Return a list of existing file extensions

    * print 'Return a list of existing file extensions'

    Given path '/data-import/fileExtensions'
    When method GET
    Then status 200

  Scenario: Return a list of file extensions for which import is blocked

    * print 'Return a list of file extensions for which import is blocked'

    Given path '/data-import/fileExtensions'
    And request
    """
    {
      "importBlocked": true
    }
    """
    When method GET
    Then status 200

  Scenario: Fail to delete non-existent extension

    * print 'Verify 404 response'

    * def fileId = callonce uuid

    Given path '/data-import/fileExtensions/', fileId
    When method DELETE
    Then status 404

  Scenario: Restore default file extensions

    * print 'Restore default file extensions'

    Given path '/data-import/fileExtensions/restore/default'
    And request
    """
    {
      "totalRecords": 13
    }
    """
    When method POST
    Then status 200