Feature: Tests that authority searches by a single property

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario Outline: Can search by keyword that matches '<field>' component
    Given path '/search/authorities'
    And param query = 'keyword all "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field           | value                | expectedId          |
      | sftTopicalTerm  | sft topical term     | personalAuthorityId |
      | uniformTitle    | uniform title        | personalAuthorityId |
      | sftMeetingName  | sft conference name  | meetingAuthorityId  |
      | saftMeetingName | saft conference name | meetingAuthorityId  |

  Scenario Outline: Can search by keyword that matches '<field>' component with order match
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field              | value                  | expectedId           |
      | corporateName      | a corporate name       | corporateAuthorityId |
      | sftCorporateName   | a sft corporate name   | corporateAuthorityId |
      | saftCorporateName  | a saft corporate name  | corporateAuthorityId |
      | geographicName     | a geographic name      | personalAuthorityId  |
      | sftGeographicTerm  | a sft geographic name  | personalAuthorityId  |
      | saftGeographicTerm | a saft geographic name | personalAuthorityId  |

  Scenario Outline: Can search by keyword that matches '<field>' component with any of values
    Given path '/search/authorities'
    And param query = 'keyword any "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == '#(<expectedCount>)'
    Examples:
      | field      | value | expectedCount |
      | nameFields | name  | 12            |
      | sftFields  | sft   | 6             |
      | saftFields | saft  | 6             |

  Scenario Outline: Can search by date with operators
    Given path '/search/authorities'
    And param query = 'metadata.<field> <operator> "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 21
    Examples:
      | field       | operator | value      |
      | createdDate | >=       | 2020-12-10 |
      | updatedDate | >        | 2021-03-20 |

  Scenario Outline: Can search by wildcard
    Given path '/search/authorities'
    And param query = '<field> = <value>'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field              | value            | expectedId           |
      | corporateName      | a corporate*     | corporateAuthorityId |
      | sftCorporateName   | a sft*           | corporateAuthorityId |
      | saftCorporateName  | a saft*          | corporateAuthorityId |
      | geographicName     | *name            | personalAuthorityId  |
      | sftGeographicTerm  | *geographic name | personalAuthorityId  |
      | saftGeographicTerm | *raphic name     | personalAuthorityId  |

  Scenario Outline: Can search by lccn
    Given path '/search/authorities'
    And param query = 'lccn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 3
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | value   | expectedId           |
      | 9781603 | corporateAuthorityId |
      | gf*     | meetingAuthorityId   |
