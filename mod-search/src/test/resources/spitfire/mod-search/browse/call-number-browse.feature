Feature: Tests that browse by call-numbers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}

  Scenario: Can browse around by single letter
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "F" or fullCallNumber >= "F"'
    And param limit = 11
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'TK5105.88815 . A58 2004 FT MEADE suffix-10101'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords": 1 },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "fullCallNumber": "F", "totalRecords": 0, "isAnchor": true },
      { "fullCallNumber": "GROUP Smith", "totalRecords": 1 },
      { "fullCallNumber": "J 839.20 oversize", "totalRecords": 1 },
      { "fullCallNumber": "K 28,10", "totalRecords": 1 },
      { "fullCallNumber": "R 928.28", "totalRecords": 1 },
      { "fullCallNumber": "TK5105.88815 . A58 2004 FT MEADE suffix-10101", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "C 829.27" or fullCallNumber >= "C 829.27"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'C 829.29'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords":1, "isAnchor": true },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "C 829.27" or fullCallNumber >= "C 829.27"'
    And param limit = 7
    And param precedingRecordsCount = 2
    When method GET
    Then status 200
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'J 839.20 oversize'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords":1, "isAnchor": true },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "fullCallNumber": "GROUP Smith", "totalRecords": 1 },
      { "fullCallNumber": "J 839.20 oversize", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "C 829.27" or fullCallNumber >= "C 829.27"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'C 829.29'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords": 1 },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "C 829.27" or fullCallNumber > "C 829.27"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'C 829.29'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords":0, "isAnchor": true },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber < "C 829.27" or fullCallNumber > "C 829.27"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == 'BC 22918 T21'
    Then match response.next == 'GROUP Smith'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords', 'isAnchor']") ==
    """
    [
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.28", "totalRecords": 1 },
      { "fullCallNumber": "C 829.29", "totalRecords": 1 },
      { "fullCallNumber": "GROUP Smith", "totalRecords": 1 },
    ]
    """

  Scenario: Can browse forward by single letter
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber > "A"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == 'A 52'
    Then match response.next == 'C 829.27'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords']") ==
    """
    [
      { "fullCallNumber": "A 52", "totalRecords": 2 },
      { "fullCallNumber": "AE 390", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T21", "totalRecords": 1 },
      { "fullCallNumber": "BC 22918 T22", "totalRecords": 1 },
      { "fullCallNumber": "C 829.27", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber >= "0"'
    And param limit = 6
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == '00001'
    Then match response.next == '378.14'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords']") ==
    """
    [
      { "fullCallNumber": "00001", "totalRecords": 1 },
      { "fullCallNumber": "00002", "totalRecords": 1 },
      { "fullCallNumber": "00003", "totalRecords": 1 },
      { "fullCallNumber": "325-d A-1908 (Freetown) Map", "totalRecords": 1 },
      { "fullCallNumber": "325.24", "totalRecords": 1 },
      { "fullCallNumber": "378.14", "totalRecords": 1 }
    ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/call-numbers/all/instances'
    And param query = 'fullCallNumber <= "ZZZZZZZZZZ"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 25
    Then match response.prev == 'K 28,10'
    Then match response.next == 'ZZ 920.92'
    Then match karate.jsonPath(response, "$.items[*].['fullCallNumber', 'totalRecords']") ==
    """
    [
      { "fullCallNumber": "K 28,10", "totalRecords": 1 },
      { "fullCallNumber": "R 928.28", "totalRecords": 1 },
      {
        "fullCallNumber": "TK5105.88815 . A58 2004 FT MEADE suffix-10101",
        "totalRecords": 1
      },
      {
        "fullCallNumber": "TK5105.88815 . A58 2004 FT MEADE suffix-90000",
        "totalRecords": 1
      },
      { "fullCallNumber": "ZZ 920.92", "totalRecords": 1 }
    ]
    """
    Then match karate.jsonPath(response, "$.items[*].callNumberTypeId") ==
    """
    ["512173a7-bd09-490e-b773-17d83f2b63fe", "512173a7-bd09-490e-b773-17d83f2b63fe"]
    """
