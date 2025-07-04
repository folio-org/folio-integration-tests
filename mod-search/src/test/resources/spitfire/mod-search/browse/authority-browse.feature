Feature: Tests that browse authorities by heading reference

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}

  Scenario: Can browse around by single letter
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft" or headingRef >= "a sft"'
    And param limit = 13
    When method GET
    Then status 200
    Then match response.prev == 'a corporate name'
    Then match response.next == 'a sft geographic name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a corporate name" },
      { "headingRef": "a corporate title" },
      { "headingRef": "a genre term" },
      { "headingRef": "a geographic name" },
      { "headingRef": "a personal name" },
      { "headingRef": "a personal title" },
      { "headingRef": "a sft", "isAnchor": true },
      { "headingRef": "a sft conference name" },
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title" },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" }
    ]
    """

  Scenario: Can browse around_including by matching value
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft corporate title" or headingRef >= "a sft corporate title"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference title'
    Then match response.next == 'a sft geographic name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title", "isAnchor": true },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" }
    ]
    """

  Scenario: Can browse around_including by matching value and precedingRecordsCount
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft corporate title" or headingRef >= "a sft corporate title"'
    And param limit = 7
    And param precedingRecordsCount = 2
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference title'
    Then match response.next == 'a sft personal title'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title", "isAnchor": true },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" },
      { "headingRef": "a sft personal name" },
      { "headingRef": "a sft personal title" }
    ]
    """

  Scenario: Can browse around_including by matching value and without highlight match
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft corporate title" or headingRef >= "a sft corporate title"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference title'
    Then match response.next == 'a sft geographic name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title" },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" }
    ]
    """

  Scenario: Can browse around by matching value
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft corporate title" or headingRef > "a sft corporate title"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference title'
    Then match response.next == 'a sft geographic name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title", "isAnchor": true },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" }
    ]
    """

  Scenario: Can browse around by matching value and without highlight match
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft corporate title" or headingRef > "a sft corporate title"'
    And param highlightMatch = false
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference title'
    Then match response.next == 'a sft personal name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" },
      { "headingRef": "a sft personal name" }
    ]
    """

  Scenario: Can browse forward
    Given path '/browse/authorities'
    And param query = 'headingRef > "a personal title"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft conference name'
    Then match response.next == 'a sft genre term'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft conference name" },
      { "headingRef": "a sft conference title" },
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title" },
      { "headingRef": "a sft genre term" },
    ]
    """

  Scenario: Can browse forward from the smallest value
    Given path '/browse/authorities'
    And param query = 'headingRef >= "0"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a conference name'
    Then match response.next == 'a genre term'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a conference name" },
      { "headingRef": "a conference title" },
      { "headingRef": "a corporate name" },
      { "headingRef": "a corporate title" },
      { "headingRef": "a genre term" },
    ]
    """

  Scenario: Can browse backward
    Given path '/browse/authorities'
    And param query = 'headingRef < "a sft personal title"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft corporate name'
    Then match response.next == 'a sft personal name'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft corporate name" },
      { "headingRef": "a sft corporate title" },
      { "headingRef": "a sft genre term" },
      { "headingRef": "a sft geographic name" },
      { "headingRef": "a sft personal name" }
  ]
    """

  Scenario: Can browse backward from the largest value
    Given path '/browse/authorities'
    And param query = 'headingRef <= "ZZZZZZZZZZ"'
    And param limit = 5
    When method GET
    Then status 200
    Then match response.prev == 'a sft personal title'
    Then match response.next == 'an uniform title'
    Then match karate.jsonPath(response, "$.items[*].['headingRef', 'isAnchor']") ==
    """
    [
      { "headingRef": "a sft personal title" },
      { "headingRef": "a sft topical term" },
      { "headingRef": "a sft uniform title" },
      { "headingRef": "a topical term" },
      { "headingRef": "an uniform title" }
    ]
    """
