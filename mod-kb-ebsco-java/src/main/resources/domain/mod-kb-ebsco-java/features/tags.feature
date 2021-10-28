Feature: Tags

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

#   ================= positive test cases =================

  Scenario: GET all tags with 200 on success
    Given path '/eholdings/tags'
    When method GET
    Then status 200

  Scenario: GET all tags filtered by record types with 200 on success
    Given path '/eholdings/tags'
    And param filter[rectype] = 'package'
    When method GET
    Then status 200

  Scenario: GET all unique tags with 200 on success
    Given path '/eholdings/tags/summary'
    When method GET
    Then status 200

  Scenario: GET all unique tags filtered by record types with 200 on success
    Given path '/eholdings/tags/summary'
    And param filter[rectype] = 'provider'
    When method GET
    Then status 200

#   ================= negative test cases =================

  Scenario: GET all tags filtered by record types should return 400 if filter parameter is invalid
    Given path '/eholdings/tags'
    And param filter[rectype] = 'wrongType'
    When method GET
    Then status 400

  Scenario: GET all unique tags filtered by record types should return 400 if filter parameter is invalid
    Given path '/eholdings/tags/summary'
    And param filter[rectype] = 'wrongType'
    When method GET
    Then status 400
