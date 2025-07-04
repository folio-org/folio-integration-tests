Feature: Tests that browse by subjects

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}

  Scenario: Can browse around by single letter
    Given path '/browse/subjects/instances'
    And param query = 'value < "F" or value >= "F"'
    And param limit = 11
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Church and the world.'
    Then match response.next == 'French language--Figures of speech'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "Church and the world." },
      { "totalRecords": 1, "value": "Differential equations." },
      { "totalRecords": 5, "value": "Electronic books." },
      { "totalRecords": 1, "value": "Engineering--Mathematical models." },
      { "totalRecords": 1, "value": "Essais (Montaigne, Michel de)" },
      { "totalRecords": 0, "value": "F", "isAnchor": true },
      { "totalRecords": 1, "value": "fantasy" },
      { "totalRecords": 1, "value": "Fiction" },
      { "totalRecords": 1, "value": "Folk poetry, Mongolian." },
      { "totalRecords": 1, "value": "Folk poetry." },
      { "totalRecords": 1, "value": "French language--Figures of speech" }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/subjects/instances'
    And param query = 'value < "science" or value >= "science"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Musical texts.'
    Then match response.next == 'Science Fiction.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "Musical texts." },
      { "totalRecords": 1, "value": "Persian poetry." },
      { "totalRecords": 4, "value": "science", "isAnchor": true },
      { "totalRecords": 1, "value": "Science (General)." },
      { "totalRecords": 1, "value": "Science Fiction." }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/subjects/instances'
    And param query = 'value < "history" or value >= "history"'
    And param limit = 7
    And param precedingRecordsCount = 2
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'geography'
    Then match response.next == 'Magic--Fiction'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "geography" },
      { "totalRecords": 1, "value": "Historiography." },
      { "totalRecords": 1, "value": "History", "isAnchor": true },
      { "totalRecords": 1, "value": "History." },
      { "totalRecords": 1, "value": "imaginary world" },
      { "totalRecords": 2, "value": "Literary style." },
      { "totalRecords": 1, "value": "Magic--Fiction" }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/subjects/instances'
    And param query = 'value < "history" or value >= "history"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'geography'
    Then match response.next == 'imaginary world'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "geography" },
      { "totalRecords": 1, "value": "Historiography." },
      { "totalRecords": 1, "value": "History" },
      { "totalRecords": 1, "value": "History." },
      { "totalRecords": 1, "value": "imaginary world" }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/subjects/instances'
    And param query = 'value < "history." or value > "history."'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Historiography.'
    Then match response.next == 'Literary style.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "Historiography." },
      { "totalRecords": 1, "value": "History" },
      { "totalRecords": 0, "value": "history.", "isAnchor": true },
      { "totalRecords": 1, "value": "imaginary world" },
      { "totalRecords": 2, "value": "Literary style." }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/subjects/instances'
    And param query = 'value < "history" or value > "history"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'geography'
    Then match response.next == 'Literary style.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "geography" },
      { "totalRecords": 1, "value": "Historiography." },
      { "totalRecords": 1, "value": "History." },
      { "totalRecords": 1, "value": "imaginary world" },
      { "totalRecords": 2, "value": "Literary style." }
    ]
    """

  Scenario: Can browse forward by single letter
    Given path '/browse/subjects/instances'
    And param query = 'value > "A"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'biology'
    Then match response.next == 'Engineering--Mathematical models.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "biology" },
      { "totalRecords": 1, "value": "Church and the world." },
      { "totalRecords": 1, "value": "Differential equations." },
      { "totalRecords": 5, "value": "Electronic books." },
      { "totalRecords": 1, "value": "Engineering--Mathematical models." }
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/subjects/instances'
    And param query = 'value >= "0"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'biology'
    Then match response.next == 'Engineering--Mathematical models.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "biology" },
      { "totalRecords": 1, "value": "Church and the world." },
      { "totalRecords": 1, "value": "Differential equations." },
      { "totalRecords": 5, "value": "Electronic books." },
      { "totalRecords": 1, "value": "Engineering--Mathematical models." }
    ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/subjects/instances'
    And param query = 'value <= "Z"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Science (General).'
    Then match response.next == 'Translations.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "value": "Science (General)." },
      { "totalRecords": 1, "value": "Science Fiction." },
      { "totalRecords": 1, "value": "Semantic Web" },
      { "totalRecords": 1, "value": "surgery" },
      { "totalRecords": 2, "value": "Translations." }
    ]
    """

  Scenario: Can browse 2 subjects with the same value and different authority id returned
    Given path '/browse/subjects/instances'
    And param query = 'value >= "Literary style."'
    And param limit = 1
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Literary style.'
    Then match response.next == 'Literary style.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 2, "value": "Literary style." }
    ]
    """

  Scenario: Can browse 2 subjects returned with the same value and one has authority id and other do not
    Given path '/browse/subjects/instances'
    And param query = 'value >= "French language--Figures of speech."'
    And param limit = 1
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'French language--Figures of speech.'
    Then match response.next == 'French language--Figures of speech.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 2, "value": "French language--Figures of speech." }
    ]
    """
    Then print response

  Scenario: Can browse subjects with diacritics
    Given path '/browse/subjects/instances'
    And param query = 'value >= "Montàigné"'
    And param limit = 3
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Montaigne, Michel de,--1533-1592'
    Then match response.next == 'Möntaigne, Michel de,--1533-1592.--Essais'
    Then match response.items[*] ==
    """
    [
      {"value":"Montaigne, Michel de,--1533-1592","totalRecords":1},
      {"value":"Montaigne, Michel de,--1533-1592--Style.","totalRecords":1},
      {"value":"Möntaigne, Michel de,--1533-1592.--Essais","totalRecords":1}
    ]
    """
    Then print response