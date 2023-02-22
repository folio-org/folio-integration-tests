Feature: Tests that browse by contributors

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario: Can browse around by single letter
    Given path '/browse/contributors/instances'
    And param query = 'name < "F" or name >= "F"'
    And param limit = 11
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Brie'
    Then match response.next == 'John, Lennon'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Celin, Cerol (Cerol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Clark, Carol (Carol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Darth Vader (The father)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": true,
        "totalRecords": 0,
        "name": "F"
      },
      {
        "isAnchor": false,
        "totalRecords": 3,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Falcon Griffin",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "Farmer",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "Frank Foster",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Frank Fosters",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "John, Lennon",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/contributors/instances'
    And param query = 'name < "Frank Foster" or name >= "Frank Foster"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Falcon Griffin'
    Then match response.next == 'John, Lennon'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 3,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Falcon Griffin",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "Farmer",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": true,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "Frank Foster",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Frank Fosters",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "John, Lennon",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/contributors/instances'
    And param query = 'name < "brie" or name >= "brie"'
    And param limit = 7
    And param precedingRecordsCount = 2
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Antoniou, Grigoris'
    Then match response.next == 'Darth Vader (The father)'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Antoniou, Grigoris",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": true,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Celin, Cerol (Cerol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Clark, Carol (Carol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Darth Vader (The father)",
        "contributorTypeId": ["null"]
      }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/contributors/instances'
    And param query = 'name < "brie" or name >= "brie"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Antoniou, Grigoris'
    Then match response.next == 'Celin, Cerol (Cerol E.)'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Antoniou, Grigoris",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Celin, Cerol (Cerol E.)",
        "contributorTypeId": ["null"]
      }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/contributors/instances'
    And param query = 'name < "brie." or name > "brie."'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Ben'
    Then match response.next == 'Clark, Carol (Carol E.)'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": true,
        "totalRecords": 0,
        "name": "brie."
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Celin, Cerol (Cerol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Clark, Carol (Carol E.)",
        "contributorTypeId": ["null"]
      }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/contributors/instances'
    And param query = 'name < "brie" or name > "brie"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Antoniou, Grigoris'
    Then match response.next == 'Clark, Carol (Carol E.)'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Antoniou, Grigoris",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Celin, Cerol (Cerol E.)",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Clark, Carol (Carol E.)",
        "contributorTypeId": ["null"]
      }
    ]
    """

  Scenario: Can browse forward by single letter
    Given path '/browse/contributors/instances'
    And param query = 'name > "A"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Abraham'
    Then match response.next == 'Brie.'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Abraham",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Antoniou, Grigoris",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      }
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/contributors/instances'
    And param query = 'name >= "0"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'Abraham'
    Then match response.next == 'Brie.'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Abraham",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Antoniou, Grigoris",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17f3-4c13-a9f8-23845bb210aa",
        "name": "Ben",
        "contributorTypeId": ["null"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "e8b311a6-3b21-43f2-a269-dd9310cb2d0a",
        "name": "Brie.",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      }
    ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/contributors/instances'
    And param query = 'name <= "Z"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 17
    Then match response.prev == 'John, Lennon'
    Then match response.next == 'Van Helsing, Frank'
    Then match response.items[*] ==
    """
    [
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "John, Lennon",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "2e48e713-17e3-4c13-a9f8-23845bb210aa",
        "name": "Quiter",
        "contributorTypeId": ["null"],
        "authorityId": "3aba7f45-c6fd-4e49-90c9-9773edbaaa2c"
      },
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "2e48e713-17e3-4c13-a9f8-23845bb210aa",
        "name": "Quiter",
        "contributorTypeId": ["null"],
        "authorityId": "3aaa7f45-c6fd-4e49-90c9-9773edbaaa2c",
      },
      {
        "isAnchor": false,
        "totalRecords": 2,
        "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a",
        "name": "Van Harmelen, Frank",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      },
      {
        "isAnchor": false,
        "totalRecords": 1,
        "contributorNameTypeId": "d376e36c-b759-4fed-8502-7130d1eeff39",
        "name": "Van Helsing, Frank",
        "contributorTypeId": ["6e09d47d-95e2-4d8a-831b-f777b8ef6d81"]
      }
    ]
    """
