Feature: Tests that browse by call-numbers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario: Can browse around by single letter
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "F" or callNumber >= "F"'
    And param limit = 11
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.27", "fullCallNumber": "C 829.27", "totalRecords": 1 },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "shelfKey": "F", "totalRecords": 0, "isAnchor": true },
      { "shelfKey": "GROUP SMITH", "fullCallNumber": "GROUP Smith", "totalRecords": 1 },
      { "shelfKey": "J 3839.20 _OVERSIZE", "fullCallNumber": "J 839.20 oversize", "totalRecords": 1 },
      { "shelfKey": "K 228 210", "fullCallNumber": "K 28,10", "totalRecords": 1 },
      { "shelfKey": "R 3928.28", "fullCallNumber": "R 928.28", "totalRecords": 1 },
      {
        "shelfKey": "TK 45105.88815 A58 42004 FT MEADE SUFFIX-90000",
        "fullCallNumber": "prefix-90000 TK5105.88815 . A58 2004 FT MEADE suffix-90000",
        "totalRecords": 1
      }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "C 3829.27" or callNumber >= "C 3829.27"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 18
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.27", "fullCallNumber": "C 829.27", "totalRecords": 1, "isAnchor": true },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "C 3829.27" or callNumber >= "C 3829.27"'
    And param limit = 7
    And param precedingRecordsCount = 2
    When method GET
    Then status 200
    Then match response.totalRecords == 18
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.27", "fullCallNumber": "C 829.27", "totalRecords": 1, "isAnchor": true },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "shelfKey": "GROUP SMITH", "fullCallNumber": "GROUP Smith", "totalRecords":1 },
      { "shelfKey": "J 3839.20 _OVERSIZE", "fullCallNumber": "J 839.20 oversize", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "C 3829.27" or callNumber > "C 3829.27"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 18
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "shelfKey": "GROUP SMITH", "fullCallNumber": "GROUP Smith", "totalRecords":1 }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "C 3829.27" or callNumber > "C 3829.27"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 18
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.27", "totalRecords": 0, "isAnchor": true },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber < "C 3829.27" or callNumber > "C 3829.27"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 18
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.28", "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "shelfKey": "C 3829.29", "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "shelfKey": "GROUP SMITH", "fullCallNumber": "GROUP Smith", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse forward by single letter
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber > "A"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 9
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords']") ==
    """
    [
      { "shelfKey": "A 252", "fullCallNumber": "A 52", "totalRecords": 2 },
      { "shelfKey": "AE 3390", "fullCallNumber": "AE 390", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T21", "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "shelfKey": "BC 522918 T22", "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "shelfKey": "C 3829.27", "fullCallNumber": "C 829.27", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber >= "0"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 15
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords']") ==
    """
    [
      { "shelfKey": "11", "fullCallNumber": "00001", "totalRecords": 1 },
      { "shelfKey": "12", "fullCallNumber": "00002", "totalRecords": 1 },
      { "shelfKey": "13", "fullCallNumber": "00003", "totalRecords": 1 },
      { "shelfKey": "19 A2 C 6444218 MUSIC CD", "fullCallNumber": "9A2 C0444218 Music CD", "totalRecords": 1 },
      { "shelfKey": "3325 D A 41908 FREETOWN MAP", "fullCallNumber": "325-d A-1908 (Freetown) Map", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/call-numbers/instances'
    And param query = 'callNumber <= "ZZZZZZZZZZ"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 15
    Then match karate.jsonPath(response, "$.items[*].['shelfKey', 'fullCallNumber', 'totalRecords']") ==
    """
    [
      { "shelfKey": "K 228 210", "fullCallNumber": "K 28,10", "totalRecords": 1 },
      { "shelfKey": "R 3928.28", "fullCallNumber": "R 928.28", "totalRecords": 1 },
      {
        "shelfKey": "TK 45105.88815 A58 42004 FT MEADE SUFFIX-90000",
        "fullCallNumber": "prefix-90000 TK5105.88815 . A58 2004 FT MEADE suffix-90000",
        "totalRecords": 1
      },
      {
        "shelfKey": "TK 45105.88815 A58 42004 FT MEADE V1 COPY 12 SUFFIX-10101",
        "fullCallNumber": "prefix-10101 TK5105.88815 . A58 2004 FT MEADE suffix-10101",
        "totalRecords": 1
      },
      { "shelfKey": "ZZ 3920.92", "fullCallNumber": "ZZ 920.92", "totalRecords": 1 }
    ]
    """
