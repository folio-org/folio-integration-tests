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
      | field                  | value                 | expectedId                | expectedSourceFileId           | expectedNaturalId           |
      | sftTopicalTerm         | sft topical term      | topicalAuthorityId        | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | uniformTitle           | an uniform title      | uniformAuthorityId        | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | sftUniformTitle        | sft uniform title     | uniformAuthorityId        | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | saftUniformTitle       | saft uniform title    | uniformAuthorityId        | personalAuthoritySourceFileId  | personalAuthorityNaturalId  |
      | sftMeetingNameTitle    | sft conference title  | meetingTitleAuthorityId   | meetingAuthoritySourceFileId   | meetingAuthorityNaturalId   |
      | saftMeetingNameTitle   | saft conference title | meetingTitleAuthorityId   | meetingAuthoritySourceFileId   | meetingAuthorityNaturalId   |
      | sftCorporateNameTitle  | sft corporate title   | corporateTitleAuthorityId | corporateAuthoritySourceFileId | corporateAuthorityNaturalId |
      | saftCorporateNameTitle | saft corporate title  | corporateTitleAuthorityId | corporateAuthoritySourceFileId | corporateAuthorityNaturalId |

  Scenario Outline: Can search by keyword that matches '<field>' component with order match
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field                  | value                  | expectedId                |
      | personalNameTitle      | a personal title       | personalTitleAuthorityId  |
      | sftPersonalNameTitle   | a sft personal title   | personalTitleAuthorityId  |
      | saftPersonalNameTitle  | a saft personal title  | personalTitleAuthorityId  |
      | meetingNameTitle       | a conference title     | meetingTitleAuthorityId   |
      | sftMeetingNameTitle    | sft conference title   | meetingTitleAuthorityId   |
      | saftMeetingNameTitle   | saft conference title  | meetingTitleAuthorityId   |
      | corporateNameTitle     | a corporate title      | corporateTitleAuthorityId |
      | sftCorporateNameTitle  | a sft corporate title  | corporateTitleAuthorityId |
      | saftCorporateNameTitle | a saft corporate title | corporateTitleAuthorityId |
      | geographicName         | a geographic name      | geographicAuthorityId  |
      | sftGeographicName      | a sft geographic name  | geographicAuthorityId  |
      | saftGeographicName     | a saft geographic name | geographicAuthorityId  |

  Scenario Outline: Can search by '<field>' that matches '<value>' with exact match
    Given path '/search/authorities'
    And param query = '<field> == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field                  | value                   | expectedId                |
      | personalNameTitle      | a personal title        | personalTitleAuthorityId  |
      | sftPersonalNameTitle   | a sft personal title    | personalTitleAuthorityId  |
      | saftPersonalNameTitle  | a saft personal title   | personalTitleAuthorityId  |
      | corporateNameTitle     | a corporate title       | corporateTitleAuthorityId |
      | sftCorporateNameTitle  | a sft corporate title   | corporateTitleAuthorityId |
      | saftCorporateNameTitle | a saft corporate title  | corporateTitleAuthorityId |
      | geographicName         | a geographic name       | geographicAuthorityId     |
      | sftGeographicName      | a sft geographic name   | geographicAuthorityId     |
      | saftGeographicName     | a saft geographic name  | geographicAuthorityId     |
      | topicalTerm            | a topical term          | topicalAuthorityId        |
      | sftTopicalTerm         | a sft topical term      | topicalAuthorityId        |
      | saftTopicalTerm        | a saft topical term     | topicalAuthorityId        |
      | uniformTitle           | an uniform title        | uniformAuthorityId        |
      | sftUniformTitle        | a sft uniform title     | uniformAuthorityId        |
      | saftUniformTitle       | a saft uniform title    | uniformAuthorityId        |
      | meetingNameTitle       | a conference title      | meetingTitleAuthorityId   |
      | sftMeetingNameTitle    | a sft conference title  | meetingTitleAuthorityId   |
      | saftMeetingNameTitle   | a saft conference title | meetingTitleAuthorityId   |

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
      | field                  | value            | expectedId                |
      | corporateNameTitle     | a corporate*     | corporateTitleAuthorityId |
      | sftCorporateNameTitle  | a sft*           | corporateTitleAuthorityId |
      | saftCorporateNameTitle | a saft*          | corporateTitleAuthorityId |
      | geographicName         | *name            | geographicAuthorityId     |
      | sftGeographicName      | *geographic name | geographicAuthorityId     |
      | saftGeographicName     | *raphic name     | geographicAuthorityId     |

  Scenario Outline: Can search by lccn
    Given path '/search/authorities'
    And param query = 'lccn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == '#(<totalRecords>)'
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | value   | expectedId           | totalRecords
      | 9781604 | corporateAuthorityId | 3
      | gf*     | meetingAuthorityId   | 6

  Scenario Outline: Search result includes Number of linked Titles
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.authorities[0].numberOfTitles == '#(<expectedNumberOfTitles>)'
    Examples:
      | value                    | expectedNumberOfTitles |
      | a personal title         | 0                      |
      | a conference title       | 0                      |
      | a corporate title        | 0                      |
