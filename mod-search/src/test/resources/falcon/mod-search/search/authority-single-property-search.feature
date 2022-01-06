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
      | field            | value                | expectedId  |
      | personalName     | personal name        | authorityId |
      | sftPersonalName  | a saft personal name | authorityId |
      | saftPersonalName | a saft personal name | authorityId |
      | uniformTitle     | an uniform title     | authorityId |

  Scenario Outline: Can search by keyword that matches '<field>' component with order match
    Given path '/search/authorities'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field              | value                  | expectedId  |
      | corporateName      | corporateName          | authorityId |
      | sftCorporateName   | a sft corporateName    | authorityId |
      | saftCorporateName  | a saft corporateName   | authorityId |
      | geographicName     | geographic name        | authorityId |
      | sftGeographicTerm  | a sft geographic name  | authorityId |
      | saftGeographicTerm | a saft geographic name | authorityId |

  Scenario Outline: Can search by keyword that matches '<field>' component with any of values
    Given path '/search/authorities'
    And param query = 'keyword any "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field            | value                | expectedId  |
      | personalName     | personal name        | authorityId |
      | sftPersonalName  | a saft personal name | authorityId |
      | saftPersonalName | a saft personal name | authorityId |
      | uniformTitle     | an uniform title     | authorityId |

  Scenario Outline: Can search by date with operators
    Given path '/search/authorities'
    And param query = 'metadata.<field> <operator> "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field       | operator | value      | expectedId  |
      | createdDate | <=       | 2020-12-10 | authorityId |
      | createdDate | >        | 2020-12-10 | authorityId |
      | updatedDate | <        | 2021-03-20 | authorityId |
      | updatedDate | >=       | 2021-03-10 | authorityId |

  Scenario Outline: Can search by wildcard
    Given path '/search/authorities'
    And param query = '<field> = <value>'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(<expectedId>)'
    Examples:
      | field              | value            | expectedId  |
      | corporateName      | corporate*       | authorityId |
      | sftCorporateName   | a sft*           | authorityId |
      | saftCorporateName  | a saft*          | authorityId |
      | geographicName     | *name            | authorityId |
      | sftGeographicTerm  | *geographic name | authorityId |
      | saftGeographicTerm | *raphic name     | authorityId |

  Scenario Outline: Can search by lccn
    Given path '/search/authorities'
    And param query = 'lccn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[0].id == '#(webSemanticInstance)'
    Examples:
      | value    |
      | 84641839 |
      | 846*     |
