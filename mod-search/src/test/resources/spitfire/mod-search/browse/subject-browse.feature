Feature: Tests that browse by subjects

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario: Can browse around by single letter
    Given path '/browse/subjects/instances'
    And param query = 'subject < "F" or subject >= "F"'
    And param limit = 11
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Church and the world.'
    Then match response.next == 'French language--Figures of speech'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "Church and the world." },
      { "totalRecords": 1, "subject": "Differential equations." },
      { "totalRecords": 5, "subject": "Electronic books." },
      { "totalRecords": 1, "subject": "Engineering--Mathematical models." },
      { "totalRecords": 1, "subject": "Essais (Montaigne, Michel de)" },
      { "totalRecords": 0, "subject": "F", "isAnchor": true },
      { "totalRecords": 1, "subject": "fantasy" },
      { "totalRecords": 1, "subject": "Fiction" },
      { "totalRecords": 1, "subject": "Folk poetry, Mongolian." },
      { "totalRecords": 1, "subject": "Folk poetry." },
      { "totalRecords": 1, "subject": "French language--Figures of speech" }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/subjects/instances'
    And param query = 'subject < "science" or subject >= "science"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Musical texts.'
    Then match response.next == 'Science Fiction.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "Musical texts." },
      { "totalRecords": 1, "subject": "Persian poetry." },
      { "totalRecords": 4, "subject": "science", "isAnchor": true },
      { "totalRecords": 1, "subject": "Science (General)." },
      { "totalRecords": 1, "subject": "Science Fiction." }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/subjects/instances'
    And param query = 'subject < "history" or subject >= "history"'
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
      { "totalRecords": 1, "subject": "geography" },
      { "totalRecords": 1, "subject": "Historiography." },
      { "totalRecords": 1, "subject": "History", "isAnchor": true },
      { "totalRecords": 1, "subject": "History." },
      { "totalRecords": 1, "subject": "imaginary world" },
      { "totalRecords": 1, "subject": "Literary style." },
      { "totalRecords": 1, "subject": "Magic--Fiction" }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/subjects/instances'
    And param query = 'subject < "history" or subject >= "history"'
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
      { "totalRecords": 1, "subject": "geography" },
      { "totalRecords": 1, "subject": "Historiography." },
      { "totalRecords": 1, "subject": "History" },
      { "totalRecords": 1, "subject": "History." },
      { "totalRecords": 1, "subject": "imaginary world" }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/subjects/instances'
    And param query = 'subject < "history." or subject > "history."'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Historiography.'
    Then match response.next == 'Literary style.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "Historiography." },
      { "totalRecords": 1, "subject": "History" },
      { "totalRecords": 0, "subject": "history.", "isAnchor": true },
      { "totalRecords": 1, "subject": "imaginary world" },
      { "totalRecords": 1, "subject": "Literary style." }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/subjects/instances'
    And param query = 'subject < "history" or subject > "history"'
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
      { "totalRecords": 1, "subject": "geography" },
      { "totalRecords": 1, "subject": "Historiography." },
      { "totalRecords": 1, "subject": "History." },
      { "totalRecords": 1, "subject": "imaginary world" },
      { "totalRecords": 1, "subject": "Literary style." }
    ]
    """

  Scenario: Can browse forward by single letter
    Given path '/browse/subjects/instances'
    And param query = 'subject > "A"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'biology'
    Then match response.next == 'Engineering--Mathematical models.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "biology" },
      { "totalRecords": 1, "subject": "Church and the world." },
      { "totalRecords": 1, "subject": "Differential equations." },
      { "totalRecords": 5, "subject": "Electronic books." },
      { "totalRecords": 1, "subject": "Engineering--Mathematical models." }
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/subjects/instances'
    And param query = 'subject >= "0"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'biology'
    Then match response.next == 'Engineering--Mathematical models.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "biology" },
      { "totalRecords": 1, "subject": "Church and the world." },
      { "totalRecords": 1, "subject": "Differential equations." },
      { "totalRecords": 5, "subject": "Electronic books." },
      { "totalRecords": 1, "subject": "Engineering--Mathematical models." }
    ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/subjects/instances'
    And param query = 'subject <= "Z"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.totalRecords == 35
    Then match response.prev == 'Science (General).'
    Then match response.next == 'Translations.'
    Then match response.items[*] ==
    """
    [
      { "totalRecords": 1, "subject": "Science (General)." },
      { "totalRecords": 1, "subject": "Science Fiction." },
      { "totalRecords": 1, "subject": "Semantic Web" },
      { "totalRecords": 1, "subject": "surgery" },
      { "totalRecords": 2, "subject": "Translations." }
    ]
    """