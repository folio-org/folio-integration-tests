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
    Then match response.authorities[0].sourceFileId == '#(<expectedSourceFileId>)'
    Then match response.authorities[0].naturalId == '#(<expectedNaturalId>)'
    Examples:
      | field                  | value                 | expectedId           | expectedSourceFileId           | expectedNaturalId           |
      | sftTopicalTerm         | sft topical term      | personalAuthorityId  | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | uniformTitle           | an uniform title      | personalAuthorityId  | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | sftUniformTitle        | sft uniform title     | personalAuthorityId  | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | saftUniformTitle       | saft uniform title    | personalAuthorityId  | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | sftMeetingNameTitle    | sft conference title  | meetingAuthorityId   | meetingAuthoritySourceFileId   | meetingAuthorityNaturalId   |
      | saftMeetingNameTitle   | saft conference title | meetingAuthorityId   | meetingAuthoritySourceFileId   | meetingAuthorityNaturalId   |
      | sftCorporateNameTitle  | sft corporate title   | corporateAuthorityId | corporateAuthoritySourceFileId | corporateAuthorityNaturalId |
      | saftCorporateNameTitle | saft corporate title  | corporateAuthorityId | corporateAuthoritySourceFileId | corporateAuthorityNaturalId |

  Scenario Outline: Can search by keyword that matches '<field>' component with order match
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field                  | value                  | expectedId           |
      | personalNameTitle      | a personal title       | personalAuthorityId  |
      | sftPersonalNameTitle   | a sft personal title   | personalAuthorityId  |
      | saftPersonalNameTitle  | a saft personal title  | personalAuthorityId  |
      | meetingNameTitle       | a conference title     | meetingAuthorityId   |
      | sftMeetingNameTitle    | sft conference title   | meetingAuthorityId   |
      | saftMeetingNameTitle   | saft conference title  | meetingAuthorityId   |
      | corporateNameTitle     | a corporate title      | corporateAuthorityId |
      | sftCorporateNameTitle  | a sft corporate title  | corporateAuthorityId |
      | saftCorporateNameTitle | a saft corporate title | corporateAuthorityId |
      | geographicName         | a geographic name      | personalAuthorityId  |
      | sftGeographicName      | a sft geographic name  | personalAuthorityId  |
      | saftGeographicName     | a saft geographic name | personalAuthorityId  |

  Scenario Outline: Can search by '<field>' that matches '<value>' with exact match
    Given path '/search/authorities'
    And param query = '<field> == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field                  | value                   | expectedId           |
      | personalNameTitle      | a personal title        | personalAuthorityId  |
      | sftPersonalNameTitle   | a sft personal title    | personalAuthorityId  |
      | saftPersonalNameTitle  | a saft personal title   | personalAuthorityId  |
      | corporateNameTitle     | a corporate title       | corporateAuthorityId |
      | sftCorporateNameTitle  | a sft corporate title   | corporateAuthorityId |
      | saftCorporateNameTitle | a saft corporate title  | corporateAuthorityId |
      | geographicName         | a geographic name       | personalAuthorityId  |
      | sftGeographicName      | a sft geographic name   | personalAuthorityId  |
      | saftGeographicName     | a saft geographic name  | personalAuthorityId  |
      | topicalTerm            | a topical term          | personalAuthorityId  |
      | sftTopicalTerm         | a sft topical term      | personalAuthorityId  |
      | saftTopicalTerm        | a saft topical term     | personalAuthorityId  |
      | uniformTitle           | an uniform title        | personalAuthorityId  |
      | sftUniformTitle        | a sft uniform title     | personalAuthorityId  |
      | saftUniformTitle       | a saft uniform title    | personalAuthorityId  |
      | meetingNameTitle       | a conference title      | meetingAuthorityId   |
      | sftMeetingNameTitle    | a sft conference title  | meetingAuthorityId   |
      | saftMeetingNameTitle   | a saft conference title | meetingAuthorityId   |

  Scenario Outline: Can search by keyword that matches '<field>' component with any of values
    Given path '/search/authorities'
    And param query = 'keyword any "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == '#(<expectedCount>)'
    Examples:
      | field       | value | expectedCount |
      | nameFields  | name  | 12            |
      | titleFields | title | 12            |
      | sftFields   | sft   | 10            |
      | saftFields  | saft  | 10            |

  Scenario Outline: Can search by date with operators
    Given path '/search/authorities'
    And param query = 'metadata.<field> <operator> "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 30
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
      | field                  | value            | expectedId           |
      | corporateNameTitle     | a corporate*     | corporateAuthorityId |
      | sftCorporateNameTitle  | a sft*           | corporateAuthorityId |
      | saftCorporateNameTitle | a saft*          | corporateAuthorityId |
      | geographicName         | *name            | personalAuthorityId  |
      | sftGeographicName      | *geographic name | personalAuthorityId  |
      | saftGeographicName     | *raphic name     | personalAuthorityId  |

  Scenario Outline: Can search by lccn
    Given path '/search/authorities'
    And param query = 'lccn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 6
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | value   | expectedId           |
      | 9781603 | corporateAuthorityId |
      | gf*     | meetingAuthorityId   |

  Scenario Outline: Search result includes Number of linked Titles
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.authorities[0].numberOfTitles == '#(<expectedNumberOfTitles>)'
    Examples:
      | field                    | value                    | expectedNumberOfTitles |
      | personalNameTitle        | a personal title         | 1                      |
      | meetingNameTitle         | a conference title       | 0                      |
      | corporateNameTitle       | a corporate title        | 0                      |
